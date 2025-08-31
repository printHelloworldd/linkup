/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:dartz/dartz.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/repository/firestore_repository.dart';
import 'package:linkup/core/domain/repository/supabase_repository.dart';
import 'package:linkup/core/failures/failure.dart';

class GetAllUsersUsecase {
  final FirestoreRepository _firestoreRepository;
  final SupabaseRepository _supabaseRepository;

  GetAllUsersUsecase(this._firestoreRepository, this._supabaseRepository);

  Future<Either<Failure, List<UserEntity>>> call() async {
    final Either<Failure, List<UserEntity>> usersResult =
        await _firestoreRepository.getAllUsers();
    List<UserEntity> updatedUsers = [];

    if (usersResult.isLeft()) return Left(CommonFailure("Failed to get users"));

    final List<UserEntity> users = usersResult.getOrElse(() => []);

    for (var user in users) {
      final profileImage =
          await _supabaseRepository.getProfileImageUrl(user.id);

      final UserEntity updatedUser =
          user.copyWith(profileImageUrl: profileImage);

      updatedUsers.add(updatedUser);
    }

    return Right(updatedUsers);
  }
}
