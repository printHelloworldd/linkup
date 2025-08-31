/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'dart:typed_data';

import 'package:linkup/core/data/datasources/remote/supabase_datasource.dart';
import 'package:linkup/core/domain/repository/supabase_repository.dart';

class SupabaseRepositoryImpl implements SupabaseRepository {
  final SupabaseDatasource supabaseDatasource;

  SupabaseRepositoryImpl({required this.supabaseDatasource});

  @override
  Future<void> uploadProfileImage(String userID, Uint8List binaryImage) async {
    await supabaseDatasource.uploadProfileImage(userID, binaryImage);
  }

  @override
  Future<String?> getProfileImageUrl(String userID) async {
    return await supabaseDatasource.getProfileImageUrl(userID);
  }
}
