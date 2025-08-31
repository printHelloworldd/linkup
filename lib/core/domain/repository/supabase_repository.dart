/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'dart:typed_data';

abstract class SupabaseRepository {
  Future<void> uploadProfileImage(String userID, Uint8List binaryImage);
  Future<String?> getProfileImageUrl(String userID);
}
