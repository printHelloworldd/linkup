/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:linkup/core/domain/repository/firestore_repository.dart';

class UnblockUserUc {
  final FirestoreRepository firestoreRepository;

  UnblockUserUc({
    required this.firestoreRepository,
  });

  Future<void> call(String blockedUserID, String currentUserID) async {
    await firestoreRepository.unblockUser(blockedUserID, currentUserID);
  }
}
