/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/core/domain/repository/database_repository.dart';

class UpdateTypingStatusUc {
  final DatabaseRepository _repository;

  UpdateTypingStatusUc(this._repository);

  Future<void> call(bool status) async {
    await _repository.updateUserTypingStatus(status);
  }
}
