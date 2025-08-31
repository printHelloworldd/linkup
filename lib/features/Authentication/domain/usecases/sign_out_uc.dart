/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/features/Authentication/domain/repository/firebase_auth_repository.dart';

class SignOutUc {
  final FirebaseAuthRepository _repository;

  SignOutUc(this._repository);

  Future<void> call() async {
    _repository.signOut();
  }
}
