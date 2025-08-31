/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:linkup/core/failures/failure.dart';

abstract class FirebaseAuthRepository {
  Future<Either<Failure, UserCredential>> signUp(String email, password);
  Future<Either<Failure, UserCredential>> signIn(String email, password);
  Future<Either<Failure, UserCredential>> signInViaGoogle();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendVerificationEmail();
  String? getCurrentUserEmail();
  String? getCurrentUserID();
  bool checkEmailVerification();
  Future<void> reloadCurrentUser();
  Future<void> signOut();
  // Future signUpViaGoogle();
}
