import 'package:flutter/material.dart';

class ChatsListProvider extends ChangeNotifier {
  bool isEditing = false;
  List<String> selectedChatsIDs = [];

  void toggleEditingMode() {
    if (isEditing) {
      selectedChatsIDs.clear();
    }

    isEditing = !isEditing;

    notifyListeners();
  }

  void toggleChat(String chatID) {
    if (selectedChatsIDs.contains(chatID)) {
      selectedChatsIDs.remove(chatID);
    } else {
      selectedChatsIDs.add(chatID);
    }

    notifyListeners();
  }
}
