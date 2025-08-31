/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:dartz/dartz.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/failures/failure.dart';

abstract class FirestoreRepository {
  Future<void> insertUserToFirestore(UserEntity user);
  Future<void> updateUserData(UserEntity user);
  Future<bool> isUserCreated(String userID);
  Future<Either<Failure, List<UserEntity>>> getAllUsers();
  Future<Either<Failure, UserEntity?>> getUserData(String userID);
  Future<void> blockUser(String blockUserID, String currentUserID);
  Future<void> unblockUser(String blockedUserID, String currentUserID);
  Future<Either<Failure, List<UserEntity>>> getAllBlockedUsers(
      String currentUserID);
}
