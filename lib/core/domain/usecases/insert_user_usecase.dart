/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/repository/app_database_repository.dart';

class InsertUserUsecase {
  final AppDatabaseRepository _appDatabaseRepository;

  InsertUserUsecase(this._appDatabaseRepository);

  Future<void> call(UserEntity user) async {
    await _appDatabaseRepository.insertUserToHive(user);
  }
}
