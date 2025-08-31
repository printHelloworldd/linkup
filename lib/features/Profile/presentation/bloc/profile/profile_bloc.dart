// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/core/domain/entities/user/private_data_entity.dart';
import 'package:linkup/core/domain/entities/user/restricted_data_entity.dart';

import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/usecases/crypto/recover_data_uc.dart';
import 'package:linkup/core/domain/usecases/get_user_uc.dart';
import 'package:linkup/core/domain/usecases/insert_user_usecase.dart';
import 'package:linkup/core/domain/entities/hobby_entity.dart';
import 'package:linkup/core/domain/usecases/insert_user_usecase_to_rdb.dart';
import 'package:linkup/core/domain/usecases/update_user_uc.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/features/Authentication/domain/entity/cryptography_entity.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  // final GetUserUsecase getUserUsecase;
  final GetUserUc getUserUc;
  final InsertUserUsecase insertUserUsecase;
  final InsertUserUsecaseToRdb insertUserUsecaseToRdb;
  final UpdateUserUc updateUserUc;
  final RecoverDataUc recoverDataUc;

  UserEntity? cachedUserData;

  ProfileBloc({
    required this.getUserUc,
    required this.insertUserUsecase,
    required this.insertUserUsecaseToRdb,
    required this.updateUserUc,
    required this.recoverDataUc,
  }) : super(ProfileInitial()) {
    on<GetUserEvent>((event, emit) async {
      emit(GettingUserState());

      final Either<Failure, Option<UserEntity?>> userResult =
          await getUserUc(event.userID);

      userResult.fold((failure) {
        if (kDebugMode) {
          print("Failed to get user data! ${failure.message}");
        }
        emit(GettingUserFailureState(exception: failure));
      }, (userO) {
        final UserEntity? user = userO.getOrElse(() => null);

        cachedUserData = user;

        final bool isPrivateDataEmpty =
            UserEntity.isPrivateDataEmpty(user?.privateDataEntity);

        final bool isRestrictedDataEmpty =
            UserEntity.isRestrictedDataEmpty(user?.restrictedDataEntity);

        emit(
          GotUserState(
            user: cachedUserData,
            isCryptoDataEmpty: isRestrictedDataEmpty || isPrivateDataEmpty,
          ),
        );
      });

      // final user = await getUserUsecase();

      // if (user == null) {
      //   final user = await getUserFromFirestoreUsecase(event.userID);
      //   cachedUserData = user;
      //   await insertUserUsecase(user);

      //   emit(GotUserState(user: user));
      // } else {
      //   cachedUserData = user;
      //   // print(
      //   //   UserEntity(
      //   //     id: user.id,
      //   //     email: user.email,
      //   //     fullName: user.fullName,
      //   //     hobbies: user.hobbies,
      //   //     age: user.age,
      //   //     gender: user.gender,
      //   //     country: user.country,
      //   //     city: user.city,
      //   //     bio: user.bio,
      //   //     socialMediaLinks: user.socialMediaLinks,
      //   //   ),
      //   // );

      //   emit(GotUserState(user: user));
      // }
    });

    on<GetUserFromFirestoreEvent>((event, emit) async {
      emit(GettingUserState());

      final Either<Failure, Option<UserEntity?>> userResult =
          await getUserUc(event.userID);

      userResult.fold((failure) {
        if (kDebugMode) {
          print("Failed to get user data from Firestore! ${failure.message}");
        }
        emit(GettingUserFailureState(exception: failure));
      }, (userO) {
        final UserEntity? user = userO.getOrElse(() => null);
        cachedUserData = user;

        final bool isPrivateDataEmpty =
            UserEntity.isPrivateDataEmpty(user?.privateDataEntity);

        final bool isRestrictedDataEmpty =
            UserEntity.isRestrictedDataEmpty(user?.restrictedDataEntity);

        emit(
          GotUserState(
            user: user,
            isCryptoDataEmpty: isRestrictedDataEmpty || isPrivateDataEmpty,
          ),
        );
      });
    });

    // TODO: Подкорректировать логику обновления пользователя
    on<UpdateUserEvent>((event, emit) async {
      final String? blockedUser = event.blockedUser;

      if (blockedUser == null) {
        emit(GettingUserState());

        final updatedUser = cachedUserData!.copyWith(
          fullName: event.fullName ?? cachedUserData!.fullName,
          age: event.age ?? cachedUserData!.age,
          gender: event.gender ?? cachedUserData!.gender,
          hobbies: event.hobbies ?? cachedUserData!.hobbies,
          country: event.country ?? cachedUserData!.country,
          city: event.city ?? cachedUserData!.city,
          profileImage: event.profileImage ?? cachedUserData!.profileImage,
          // profileImageUrl:
          //     event.profileImageUrl ?? cachedUserData!.profileImageUrl,
          bio: event.bio ?? cachedUserData!.bio,
          socialMediaLinks:
              event.socialMediaLinks ?? cachedUserData!.socialMediaLinks,
          // privateKey: event.privateKey ?? cachedUserData!.privateKey,
          privateDataEntity:
              event.privateDataEntity ?? cachedUserData!.privateDataEntity,
          restrictedDataEntity: event.restrictedDataEntity ??
              cachedUserData!.restrictedDataEntity,
        );
        cachedUserData = updatedUser;

        // if (event.privateKey == null) {
        // await insertUserUsecase(updatedUser);
        final profileImageUrl = await updateUserUc(updatedUser);

        // Update profile image url
        if (profileImageUrl != null) {
          cachedUserData = updatedUser.copyWith(
            profileImageUrl: profileImageUrl,
          );
        }
        // } else {
        //   await savePrivateKeyUc(cachedUserData!.id, event.privateKey!);
        // }

        if (event.cryptographyEntity != null) {
          await recoverDataUc(event.cryptographyEntity!);
        }

        final Either<Failure, Option<UserEntity?>> userResult =
            await getUserUc(updatedUser.id);

        userResult.fold((failure) {
          if (kDebugMode) {
            print("Failed to get user data from Firestore! ${failure.message}");
          }
          emit(GettingUserFailureState(exception: failure));
        }, (userO) {
          final UserEntity? user = userO.getOrElse(() => null);
          cachedUserData = user;

          final bool isPrivateDataEmpty =
              UserEntity.isPrivateDataEmpty(user?.privateDataEntity);

          final bool isRestrictedDataEmpty =
              UserEntity.isRestrictedDataEmpty(user?.restrictedDataEntity);

          emit(
            GotUserState(
              user: user,
              isCryptoDataEmpty: isRestrictedDataEmpty || isPrivateDataEmpty,
            ),
          );
        });
      } else {
        final blockedUsers = cachedUserData!.blockedUsers;

        if (blockedUsers.contains(blockedUser)) {
          blockedUsers.remove(blockedUser);
        } else {
          blockedUsers.add(blockedUser);
        }

        final updatedUser = cachedUserData!.copyWith(
          blockedUsers: blockedUsers,
        );
        cachedUserData = updatedUser;
      }
    });
  }
}
