/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/core/domain/repository/database_repository.dart';

class GetUserStatusUc {
  final DatabaseRepository _databaseRepository;

  GetUserStatusUc(this._databaseRepository);

  Stream<bool> call(String userID) {
    return _databaseRepository.getUserStatus(userID);
  }
}
