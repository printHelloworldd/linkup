/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:linkup/features/Authentication/domain/repository/firebase_auth_repository.dart';

class SendVerificationEmailUC {
  FirebaseAuthRepository firebaseAuthRepository;

  SendVerificationEmailUC({
    required this.firebaseAuthRepository,
  });

  Future<void> call() async {
    await firebaseAuthRepository.sendVerificationEmail();
  }
}
