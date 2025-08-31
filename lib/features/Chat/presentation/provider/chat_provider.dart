import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  List<Map<String, dynamic>> selectedMessages = [];
  bool isEditing = false;
  bool isReplying = false;
  String replyTo = "";
  String replyMessage = "";

  void toggleMessage(String messageID, String messageText,
      Timestamp messageTimestamp, String senderID) {
    if (selectedMessages.any((message) => message["id"] == messageID)) {
      selectedMessages.removeWhere((message) => message["id"] == messageID);
    } else {
      selectedMessages.add({
        "id": messageID,
        "text": messageText,
        "timestamp": messageTimestamp,
        "senderID": senderID,
      });
    }

    notifyListeners();
  }

  void toggleEditingMode() {
    if (isEditing) {
      selectedMessages.clear();
    }

    isEditing = !isEditing;

    notifyListeners();
  }

  void toggleReplyingMode(bool mode) {
    isReplying = mode;

    if (!mode) {
      replyTo = "";
      replyMessage = "";
    }

    notifyListeners();
  }

  void changeReplyData(String fullName, String text) {
    replyTo = fullName;
    replyMessage = text;

    notifyListeners();
  }
}
