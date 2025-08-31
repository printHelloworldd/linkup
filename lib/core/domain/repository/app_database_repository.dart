/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/core/domain/entities/user/user_entity.dart';

abstract class AppDatabaseRepository {
  Future<void> insertUserToHive(UserEntity user);
  Future<UserEntity?> getUserFromHive();
}
