/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDatasource {
  Supabase supabase = Supabase.instance;

  Future<void> uploadProfileImage(String userID, Uint8List binaryImage) async {
    await supabase.client.storage.from("profile_images").uploadBinary(
          "$userID/profile_image",
          binaryImage,
          fileOptions:
              const FileOptions(upsert: true, contentType: "image/jpeg"),
        );
  }

  Future<String?> getProfileImageUrl(String userID) async {
    if (await doesImageExist("$userID/profile_image")) {
      String imageUrl = supabase.client.storage
          .from("profile_images")
          .getPublicUrl("$userID/profile_image");

      // to avoid caching
      imageUrl = Uri.parse(imageUrl).replace(queryParameters: {
        "t": DateTime.now().millisecondsSinceEpoch.toString(),
      }).toString();

      return imageUrl;
    } else {
      return null;
    }
  }

  Future<bool> doesImageExist(String path) async {
    final response = await supabase.client.storage
        .from('profile_images')
        .list(path: path.substring(0, path.lastIndexOf('/')));
    return response.any((file) => file.name == path.split('/').last);
  }

  Future<void> saveFcmToken(String userID, String fcmToken) async {
    final existing = await supabase.client
        .from('profiles')
        .select()
        .eq('id', userID)
        .maybeSingle();

    if (existing != null) {
      await supabase.client
          .from('profiles')
          .update({'fcm_token': fcmToken}).eq('id', userID);
    } else {
      await supabase.client.from('profiles').insert({
        'id': userID,
        'fcm_token': fcmToken,
      });
    }
  }

  Future<String?> getFcmToken(String userID) async {
    final data = await supabase.client
        .from('profiles')
        .select()
        .eq('id', userID)
        .maybeSingle();

    final String? token = data?["fcm_token"];

    return token;
  }
}
