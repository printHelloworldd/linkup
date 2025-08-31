/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/core/domain/repository/firebase_messaging_repository.dart';

class InitNotificationsUc {
  final FirebaseMessagingRepository _repository;

  InitNotificationsUc(this._repository);

  Future<void> call(String userID) async {
    await _repository.initNotifications(userID);
  }
}
