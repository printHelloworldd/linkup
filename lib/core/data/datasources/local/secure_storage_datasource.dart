/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:linkup/features/Authentication/data/model/private_cryptography_model.dart';

/// A data source for securely storing sensitive data such as
/// private cryptographic keys and chat-specific shared keys.
///
/// This class uses [FlutterSecureStorage] to ensure that all data is
/// encrypted and safely stored on the device.
///
/// It is typically used for:
/// - Storing and retrieving private user cryptographic data
/// - Saving FCM tokens per user
/// - Managing per-chat encryption keys
class SecureStorageDatasource {
  /// Secure key-value storage instance.
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  /// Saves the private cryptographic data for a specific user.
  ///
  /// The data is stored as a JSON-encoded string using a key format:
  /// `"<userID>-PrivateData"`.
  Future<void> savePrivateData(
      {required String userID,
      required PrivateCryptographyModel privateData}) async {
    try {
      final String key = "$userID-PrivateData";
      final String encodedJson = json.encode(privateData.toJson());

      await storage.write(key: key, value: encodedJson);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Retrieves the private cryptographic data for a specific user.
  ///
  /// Returns a [PrivateCryptographyModel] if data exists, otherwise `null`.
  Future<PrivateCryptographyModel?> getPrivateData(String userID) async {
    try {
      final String key = "$userID-PrivateData";
      final String? rawData = await storage.read(key: key);

      if (rawData != null) {
        final Map<String, dynamic> decodedJson = json.decode(rawData);

        return PrivateCryptographyModel.fromJson(decodedJson);
      }

      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Saves the Firebase Cloud Messaging token for a specific user.
  ///
  /// Stored using key format: `"<userID>-FCMToken"`.
  Future<void> saveToken(String userID, String token) async {
    try {
      final String key = "$userID-FCMToken";
      await storage.write(key: key, value: token);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Retrieves the Firebase Cloud Messaging token for a specific user.
  ///
  /// Returns the token as [String] if available, otherwise `null`.
  Future<String?> getToken(String userID) async {
    try {
      final String key = "$userID-FCMToken";
      String? token = await storage.read(key: key);

      return token;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Saves the symmetric shared key for a specific chat.
  ///
  /// The [chatID] is used directly as the key for storage.
  Future<void> saveChatSharedKey(
      {required String chatID, required String sharedKey}) async {
    try {
      await storage.write(key: chatID, value: sharedKey);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Retrieves the symmetric shared key for a specific chat.
  ///
  /// Returns the key as [String] if it exists, otherwise `null`.
  Future<String?> getChatSharedKey({required String chatID}) async {
    try {
      final String? sharedKey = await storage.read(key: chatID);

      return sharedKey;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
