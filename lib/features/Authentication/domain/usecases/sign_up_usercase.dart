/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:linkup/core/domain/repository/firestore_repository.dart';
import 'package:linkup/core/domain/repository/secure_storage_repository.dart';
import 'package:linkup/core/domain/repository/crypto_repository.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/features/Authentication/domain/repository/firebase_auth_repository.dart';

class SignUpUsercase {
  final FirebaseAuthRepository firebaseAuthRepository;
  final CryptoRepository cryptoRepository;
  final SecureStorageRepository secureStorageRepository;
  final FirestoreRepository firestoreRepository;

  SignUpUsercase({
    required this.firebaseAuthRepository,
    required this.cryptoRepository,
    required this.secureStorageRepository,
    required this.firestoreRepository,
  });

  Future<Either<Failure, UserCredential>> call(
      String email, String password) async {
    return await firebaseAuthRepository.signUp(email, password);
  }
}
