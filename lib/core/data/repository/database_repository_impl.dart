/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/core/data/datasources/remote/database_datasource.dart';
import 'package:linkup/core/domain/repository/database_repository.dart';

class DatabaseRepositoryImpl implements DatabaseRepository {
  final DatabaseDatasource _databaseDatasource;

  DatabaseRepositoryImpl(this._databaseDatasource);

  @override
  Stream<bool> getUserStatus(String userID) {
    return _databaseDatasource.getUserStatus(userID);
  }

  @override
  Future<void> updateUserStatus(bool status) async {
    await _databaseDatasource.updateUserStatus(status);
  }

  @override
  Stream<bool> getUserTypingStatus(String userID) {
    return _databaseDatasource.getUserTypingStatus(userID);
  }

  @override
  Future<void> updateUserTypingStatus(bool status) async {
    await _databaseDatasource.updateUserTypingStatus(status);
  }
}
