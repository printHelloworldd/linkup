/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/core/domain/repository/database_repository.dart';

class UpdateUserStatusUc {
  final DatabaseRepository _databaseRepository;

  UpdateUserStatusUc(this._databaseRepository);

  Future<void> call(bool status) async {
    await _databaseRepository.updateUserStatus(status);
  }
}
