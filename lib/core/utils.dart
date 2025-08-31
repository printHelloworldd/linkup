import 'dart:convert';

import 'package:archive/archive.dart';

/// A collection of utility methods for string compression, decompression,
/// splitting, and unique identifier generation.
///
/// Includes helper functions such as BZip2 compression/decompression,
/// string splitting into parts, and generating unique chat IDs.
class Utils {
  /// Compresses a UTF-8 [input] string using BZip2 compression.
  ///
  /// Returns the compressed data as a list of bytes.
  static List<int> compressBzip2(String input) {
    List<int> inputBytes = utf8.encode(input);
    List<int> compressedBytes = BZip2Encoder().encode(inputBytes);
    return compressedBytes;
  }

  /// Decompresses a BZip2-compressed [compressedInput] byte list back into a string.
  ///
  /// Returns the original UTF-8 string.
  static String decompressBzip2(List<int> compressedInput) {
    // List<int> compressedBytes = base64.decode(compressedInput);
    List<int> decompressedBytes = BZip2Decoder().decodeBytes(compressedInput);
    return utf8.decode(decompressedBytes);
  }

  /// Splits a string [str] into [partsCount] approximately equal parts.
  ///
  /// Returns a list of substrings. Useful when needing to chunk data
  /// for storage or transmission.
  static List<String> splitStringIntoParts(String str, int partsCount) {
    int partLength = (str.length / partsCount).ceil();
    List<String> parts = [];

    for (int i = 0; i < partsCount; i++) {
      int start = i * partLength;
      int end = (i + 1) * partLength;
      parts.add(str.substring(start, end > str.length ? str.length : end));
    }

    return parts;
  }

  /// Reconstructs a full string from its [parts] by concatenating them.
  static String joinStringFromParts(List<String> parts) {
    return parts.join('');
  }

  /// Generates a consistent and unique chat ID between two users,
  /// based on their [currentUserID] and [otherUserID].
  ///
  /// The IDs are sorted lexicographically before being joined with an underscore,
  /// ensuring the result is the same regardless of ID order.
  static String getChatID(
      {required String currentUserID, required String otherUserID}) {
    List<String> ids = [currentUserID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    return chatRoomID;
  }

  /// Extracts the user ID of the other participant in a chat from the chat ID.
  ///
  /// The [chatID] is expected to be a string combining two user IDs separated by an underscore (`_`),
  /// for example: `'user1_user2'`.
  ///
  /// The [excludedUserID] is the ID of the user, which should be excluded from the chat ID.
  ///
  /// Returns the ID of the other user participating in the chat.
  ///
  /// Example:
  /// ```dart
  /// final otherUserID = getUserIDFromChatID(
  ///   chatID: 'user1_user2',
  ///   excludedUserID: 'user1',
  /// );
  /// print(otherUserID); // Outputs: 'user2'
  /// ```
  static String getUserIDFromChatID(
      {required String chatID, required String excludedUserID}) {
    List<String> chatIDParts = chatID.split("_");
    chatIDParts.remove(excludedUserID);
    String userID = chatIDParts.single;

    return userID;
  }
}
