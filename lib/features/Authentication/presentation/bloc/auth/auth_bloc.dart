/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/core/domain/usecases/init_notifications_uc.dart';
import 'package:linkup/core/domain/entities/hobby_entity.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/usecases/insert_user_usecase_to_rdb.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/features/Authentication/domain/usecases/check_email_verification_uc.dart';
import 'package:linkup/features/Authentication/domain/usecases/google_sign_in_usecase.dart';
import 'package:linkup/core/domain/usecases/insert_user_usecase.dart';
import 'package:linkup/features/Authentication/domain/usecases/reload_current_user_uc.dart';
import 'package:linkup/features/Authentication/domain/usecases/send_psw_reset_email.dart';
import 'package:linkup/features/Authentication/domain/usecases/send_verification_email_uc.dart';
import 'package:linkup/features/Authentication/domain/usecases/sign_in_usercase.dart';
import 'package:linkup/features/Authentication/domain/usecases/sign_out_uc.dart';
import 'package:linkup/features/Authentication/domain/usecases/sign_up_usercase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUsercase signUpUsercase;
  final SignInUsercase signInUsercase;
  final GoogleSignInUsecase googleSignInUsecase;
  final InsertUserUsecase insertUserUsecase;
  final InsertUserUsecaseToRdb insertUserUsecaseToRdb;
  final InitNotificationsUc initNotificationsUc;
  final SendPswResetEmail sendPswResetEmail;
  final SendVerificationEmailUC sendVerificationEmailUC;
  final CheckEmailVerificationUc checkEmailVerificationUc;
  final ReloadCurrentUserUc reloadCurrentUserUc;
  final SignOutUc signOutUc;

  UserEntity user = const UserEntity(
    id: "",
    email: "",
    fullName: "",
    hobbies: [],
    blockedUsers: [],
  );

  bool isEmailVerified = false;

  AuthBloc({
    required this.signUpUsercase,
    required this.signInUsercase,
    required this.googleSignInUsecase,
    required this.insertUserUsecase,
    required this.insertUserUsecaseToRdb,
    required this.initNotificationsUc,
    required this.sendPswResetEmail,
    required this.sendVerificationEmailUC,
    required this.checkEmailVerificationUc,
    required this.reloadCurrentUserUc,
    required this.signOutUc,
  }) : super(AuthInitial()) {
    on<SignUp>((event, emit) async {
      try {
        emit(AuthSigningIn());

        final Either<Failure, UserCredential> result =
            await signUpUsercase(event.email, event.password);

        result.fold((failure) {
          if (kDebugMode) {
            print("Failed to sign user up: ${failure.message}");
          }

          emit(AuthSigningUpFailure(exception: failure));
        }, (userCredential) {
          user = user.copyWith(
            id: userCredential.user!.uid,
            email: userCredential.user!.email,
          );

          emit(AuthSignedIn());
        });
      } finally {
        event.completer?.complete();
      }
    });

    on<CreateUser>((event, emit) async {
      try {
        emit(CreatingUser());

        // await insertUserUsecase(user);
        await insertUserUsecaseToRdb(user: user, pin: event.pin);

        emit(CreatedUser());
      } catch (e) {
        if (kDebugMode) {
          print("Failed to create a user: $e");
        }
        emit(CreatingUserFailure());
      }
    });

    on<SignIn>((event, emit) async {
      try {
        emit(AuthSigningIn());

        await signInUsercase(event.email, event.password);

        emit(AuthSignedIn());
      } catch (e) {
        emit(AuthSigningInFailure(exception: e));

        if (kDebugMode) {
          print("EEE: $e");
        }
      } finally {
        event.completer?.complete();
      }
    });

    on<SignInViaGoogle>((event, emit) async {
      try {
        emit(AuthSigningInViaGoogle());

        await googleSignInUsecase();

        emit(AuthSignedInViaGoogle());
      } catch (e) {
        emit(AuthSigningInViaGoogleFailure(exception: e));
      }
    });

    on<SignUpViaGoogle>((event, emit) async {
      emit(AuthSigningInViaGoogle());

      final Either<Failure, UserCredential> result =
          await googleSignInUsecase();

      result.fold((failure) {
        if (kDebugMode) {
          print("Failed to sign user up via Google: ${failure.message}");
        }

        emit(AuthSigningInViaGoogleFailure(exception: failure));
      }, (userCredential) {
        user = user.copyWith(
          id: userCredential.user!.uid,
          email: userCredential.user!.email,
        );

        // // await insertUserUsecase(user);
        // await firestoreInsertUserUsecase(user: user, pin: "");

        emit(AuthSignedInViaGoogle());
      });
    });

    on<UpdateUserData>((event, emit) {
      final updatedUser = user.copyWith(
        id: event.id ?? user.id,
        email: event.email ?? user.email,
        fullName: event.fullName ?? user.fullName,
        age: event.age ?? user.age,
        gender: event.gender ?? user.gender ?? "",
        hobbies: event.hobbies ?? user.hobbies,
        country: event.country ?? user.country,
        city: event.city ?? user.city ?? "",
        profileImage: event.profileImage ?? user.profileImage,
        bio: event.bio ?? user.bio ?? "",
        socialMediaLinks: event.socialMediaLinks ?? user.socialMediaLinks ?? {},
      );

      user = updatedUser;
      // print(user);
    }); //TODO: можно вынести как Cubit

    on<InitNotifications>((event, emit) async {
      try {
        await initNotificationsUc(event.userID);
      } catch (e) {
        if (kDebugMode) {
          print("Failed to initialize FCM: $e");
        }
      }
    });

    on<SendPasswordResetEmail>((event, emit) async {
      await sendPswResetEmail(event.email);
    });

    on<SendVerificationEmail>((event, emit) async {
      await sendVerificationEmailUC();
    });

    on<CheckEmailVerification>((event, emit) {
      isEmailVerified = checkEmailVerificationUc();

      if (isEmailVerified) {
        emit(EmailVerified());
      }
    });

    on<ReloadCurrentUser>((event, emit) async {
      await reloadCurrentUserUc();
    });

    on<SignOutEvent>((event, emit) async {
      await signOutUc();
    });
  }
}
