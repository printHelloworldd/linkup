/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/features/Authentication/domain/repository/firebase_auth_repository.dart';

class GetCurrentUserEmailUc {
  final FirebaseAuthRepository firebaseAuthRepository;

  GetCurrentUserEmailUc({required this.firebaseAuthRepository});

  String? call() {
    return firebaseAuthRepository.getCurrentUserEmail();
  }
}
