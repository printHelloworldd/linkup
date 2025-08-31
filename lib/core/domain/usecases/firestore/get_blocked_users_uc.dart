/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/repository/firestore_repository.dart';
import 'package:linkup/core/failures/failure.dart';

class GetBlockedUsersUc {
  final FirestoreRepository firestoreRepository;

  GetBlockedUsersUc({
    required this.firestoreRepository,
  });

  Future<Either<Failure, List<UserEntity>>> call(String currentUserID) async {
    return await firestoreRepository.getAllBlockedUsers(currentUserID);
  }
}
