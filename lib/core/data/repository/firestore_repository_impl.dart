/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:linkup/core/data/datasources/remote/firestore_datasource.dart';
import 'package:linkup/core/data/models/user/user_model.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/repository/firestore_repository.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/features/Authentication/data/datasource/remote/firebase_auth_datasource.dart';

class FirestoreRepositoryImpl implements FirestoreRepository {
  final FirestoreDatasource firestoreDatasource;
  final FirebaseAuthDatasource firebaseAuthDatasource;

  FirestoreRepositoryImpl({
    required this.firestoreDatasource,
    required this.firebaseAuthDatasource,
  });

  @override
  Future<void> insertUserToFirestore(UserEntity user) async {
    // final updatedUser = user.copyWith(publicKey: publicKey);
    final String? userID = firebaseAuthDatasource.getCurrentUserID();
    final String? userEmail = firebaseAuthDatasource.getCurrentUserEmail();

    if (userID == null || userEmail == null) {
      throw Exception("User credentials are null");
    }

    final Map<String, dynamic> userData =
        UserModel.fromEntity(user).toJson(includeSensitiveData: false);

    if (user.id.isEmpty) {
      userData["uid"] = userID;
    }
    if (user.email.isEmpty) {
      userData["email"] = userEmail;
    }

    await firestoreDatasource.insertUser(userData: userData, userID: userID);
  }

  @override
  Future<void> updateUserData(UserEntity user) async {
    final String? currentUserID = firebaseAuthDatasource.getCurrentUserID();

    if (currentUserID == null) throw Exception("User ID is null");

    final Map<String, dynamic> userData =
        UserModel.fromEntity(user).toJson(includeSensitiveData: false);
    await firestoreDatasource.insertUser(
        userData: userData, userID: currentUserID);
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers() async {
    try {
      final String? currentUserID = firebaseAuthDatasource.getCurrentUserID();

      final rawData = await firestoreDatasource.getAllUsers(currentUserID!);

      List<UserModel> userModels =
          rawData.map((user) => UserModel.fromJson(user)).toList();
      List<UserEntity> users =
          userModels.map((user) => user.toEntity()).toList();

      return Right(users);
    } on Exception catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getUserData(String userID) async {
    try {
      final String? currentUserID = firebaseAuthDatasource.getCurrentUserID();

      final rawData =
          await firestoreDatasource.getUserData(userID, currentUserID!);

      if (rawData != null) {
        UserModel userModel = UserModel.fromJson(rawData);
        UserEntity user = userModel.toEntity();

        return Right(user);
      }

      return Left(CommonFailure("Failed to get user data: user data is null"));
    } on Exception catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }

  @override
  Future<void> blockUser(String blockUserID, String currentUserID) async {
    await firestoreDatasource.blockUser(blockUserID, currentUserID);
  }

  @override
  Future<void> unblockUser(String blockedUserID, String currentUserID) async {
    await firestoreDatasource.unblockUser(blockedUserID, currentUserID);
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getAllBlockedUsers(
      String currentUserID) async {
    try {
      final List<String> allBlockedUsersIDS =
          await firestoreDatasource.getAllBlockedUsers(currentUserID);

      List<UserEntity> allBlockedUsers = [];
      for (var blockedUserID in allBlockedUsersIDS) {
        final blockedUser =
            await firestoreDatasource.getUserData(blockedUserID, currentUserID);

        allBlockedUsers.add(UserModel.fromJson(blockedUser!).toEntity());
      }

      return Right(allBlockedUsers);
    } on Exception catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }

  @override
  Future<bool> isUserCreated(String userID) async {
    return firestoreDatasource.isUserCreated(userID);
  }
}
