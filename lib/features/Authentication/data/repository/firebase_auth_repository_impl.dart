/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/features/Authentication/data/datasource/remote/firebase_auth_datasource.dart';
import 'package:linkup/features/Authentication/domain/repository/firebase_auth_repository.dart';

class FirebaseAuthRepositoryImpl implements FirebaseAuthRepository {
  final FirebaseAuthDatasource _firebaseAuthDatasource;

  FirebaseAuthRepositoryImpl(this._firebaseAuthDatasource);

  @override
  Future<Either<Failure, UserCredential>> signUp(String email, password) async {
    try {
      final UserCredential userCredential = await _firebaseAuthDatasource
          .signUp(email: email, password: password);

      return Right(userCredential);
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseAuthFailure(e.message));
    } on Exception catch (e) {
      if (kDebugMode) {
        return Left(CommonFailure(e.toString()));
      } else {
        return Left(CommonFailure("Something went wrong. Try again later"));
      }
    }
  }

  @override
  Future<Either<Failure, UserCredential>> signIn(String email, password) async {
    try {
      final UserCredential userCredential = await _firebaseAuthDatasource
          .signIn(email: email, password: password);

      return Right(userCredential);
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseAuthFailure(e.message));
    } on Exception catch (e) {
      if (kDebugMode) {
        return Left(CommonFailure(e.toString()));
      } else {
        return Left(CommonFailure("Something went wrong. Try again later"));
      }
    }
  }

  @override
  Future<Either<Failure, UserCredential>> signInViaGoogle() async {
    try {
      final UserCredential userCredential =
          await _firebaseAuthDatasource.signInViaGoogle();

      return Right(userCredential);
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseAuthFailure(e.message));
    } on Exception catch (e) {
      if (kDebugMode) {
        return Left(CommonFailure(e.toString()));
      } else {
        return Left(CommonFailure("Something went wrong. Try again later"));
      }
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuthDatasource.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuthDatasource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> sendVerificationEmail() async {
    await _firebaseAuthDatasource.sendVerificationEmail();
  }

  @override
  bool checkEmailVerification() {
    return _firebaseAuthDatasource.checkEmailVerification();
  }

  @override
  String? getCurrentUserEmail() {
    return _firebaseAuthDatasource.getCurrentUserEmail();
  }

  @override
  Future<void> reloadCurrentUser() async {
    await _firebaseAuthDatasource.reloadCurrentUser();
  }

  @override
  String? getCurrentUserID() {
    return _firebaseAuthDatasource.getCurrentUserID();
  }

  // @override
  // Future signUpViaGoogle() async {
  //   await _firebaseAuthDatasource.signUpViaGoogle();
  // }
}
