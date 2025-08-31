/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/features/Authentication/domain/repository/firebase_auth_repository.dart';

class SignInUsercase {
  final FirebaseAuthRepository firebaseAuthRepository;

  SignInUsercase(this.firebaseAuthRepository);

  Future<Either<Failure, UserCredential>> call(String email, password) async {
    return await firebaseAuthRepository.signIn(email, password);
  }
}
