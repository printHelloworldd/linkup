/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:dartz/dartz.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/features/Authentication/domain/entity/private_cryptography_entity.dart';

abstract class SecureStorageRepository {
  Future<Either<Failure, Unit>> savePrivateData({
    required String userID,
    required PrivateCryptographyEntity privateData,
  });

  Future<Either<Failure, Option<PrivateCryptographyEntity>>> getPrivateData(
      String userID);

  Future<Either<Failure, Unit>> saveToken(String userID, String token);

  Future<Either<Failure, Option<String>>> getToken(String userID);

  Future<Either<Failure, Unit>> saveChatSharedKey(
      {required String chatID, required String sharedKey});

  Future<Either<Failure, Option<String>>> getChatSharedKey(
      {required String chatID});
}
