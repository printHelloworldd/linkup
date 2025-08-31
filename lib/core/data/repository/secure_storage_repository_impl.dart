/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';
import 'package:linkup/core/data/datasources/local/secure_storage_datasource.dart';
import 'package:linkup/core/domain/repository/secure_storage_repository.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/features/Authentication/data/datasource/remote/firebase_auth_datasource.dart';
import 'package:linkup/features/Authentication/data/model/private_cryptography_model.dart';
import 'package:linkup/features/Authentication/domain/entity/private_cryptography_entity.dart';

class SecureStorageRepositoryImpl implements SecureStorageRepository {
  final SecureStorageDatasource secureStorageDatasource;
  final FirebaseAuthDatasource firebaseAuthDatasource;

  SecureStorageRepositoryImpl({
    required this.secureStorageDatasource,
    required this.firebaseAuthDatasource,
  });

  @override
  Future<Either<Failure, Unit>> savePrivateData({
    required String userID,
    required PrivateCryptographyEntity privateData,
  }) async {
    try {
      final String? currentUserID = firebaseAuthDatasource.getCurrentUserID();

      await secureStorageDatasource.savePrivateData(
          userID: currentUserID!,
          privateData: PrivateCryptographyModel.fromEntity(privateData));

      return const Right(unit);
    } on Exception catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Option<PrivateCryptographyEntity>>> getPrivateData(
      String userID) async {
    try {
      final PrivateCryptographyModel? rawData =
          await secureStorageDatasource.getPrivateData(userID);

      if (rawData != null) {
        return Right(Some(rawData.toEntity()));
      }

      return Right(none());
    } on Exception catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Option<String>>> getChatSharedKey(
      {required String chatID}) async {
    try {
      final String? sharedKey =
          await secureStorageDatasource.getChatSharedKey(chatID: chatID);

      if (sharedKey == null) return Right(none());

      return Right(Some(sharedKey));
    } on Exception catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Option<String>>> getToken(String userID) async {
    try {
      final String? token = await secureStorageDatasource.getToken(userID);

      if (token == null) return Right(none());

      return Right(Some(token));
    } on Exception catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveChatSharedKey(
      {required String chatID, required String sharedKey}) async {
    try {
      await secureStorageDatasource.saveChatSharedKey(
          chatID: chatID, sharedKey: sharedKey);

      return const Right(unit);
    } on Exception catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveToken(String userID, String token) async {
    try {
      await secureStorageDatasource.saveToken(userID, token);

      return const Right(unit);
    } on Exception catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }
}
