/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/repository/firestore_repository.dart';
import 'package:linkup/core/domain/repository/supabase_repository.dart';

class UpdateUserUc {
  final FirestoreRepository firestoreRepository;
  final SupabaseRepository supabaseRepository;

  UpdateUserUc({
    required this.firestoreRepository,
    required this.supabaseRepository,
  });

  Future<String?> call(UserEntity user) async {
    await firestoreRepository.updateUserData(user);

    if (user.profileImage != null) {
      await supabaseRepository.uploadProfileImage(user.id, user.profileImage!);
    }

    return await supabaseRepository.getProfileImageUrl(user.id);
  }
}
