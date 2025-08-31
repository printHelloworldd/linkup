/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/core/domain/repository/database_repository.dart';

class GetUserTypingStatusUc {
  final DatabaseRepository _repository;

  GetUserTypingStatusUc(this._repository);

  Stream<bool> call(String userID) {
    return _repository.getUserTypingStatus(userID);
  }
}
