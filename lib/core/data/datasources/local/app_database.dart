/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:hive_flutter/hive_flutter.dart';

class AppDatabase {
  // TODO: Add id for key because user can have several accounts

  final _authBox = Hive.box("app_database");

  Future<Map<dynamic, dynamic>?> getUser() async {
    return await _authBox.get("user");
  }

  Future<void> insertUser(Map<String, dynamic> userData) async {
    // print(userData["socialMediaLinks"]);
    await _authBox.put("user", userData);
  }

  // Future<void> deleteUser() async {
  //   await _authBox.delete("user");
  // }
}
