import 'package:linkup/core/data/models/user/user_model.dart';
import 'package:linkup/features/Chat/data/models/message_model.dart';
import 'package:linkup/features/Chat/domain/entities/chat.dart';

class ChatModel extends ChatEntity {
  ChatModel({
    required super.chatID,
    required super.receiverUser,
    super.lastMessage,
    super.unreadMessagesCount,
    super.isPinned,
    super.isMuted,
    required super.sharedKey,
  });

  ChatEntity toEntity() {
    return ChatEntity(
      chatID: chatID,
      receiverUser: receiverUser,
      lastMessage: lastMessage,
      unreadMessagesCount: unreadMessagesCount,
      isMuted: isMuted,
      isPinned: isPinned,
      sharedKey: sharedKey,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "chatID": chatID,
      "receiverUser": UserModel.fromEntity(receiverUser)
          .toJson(includeSensitiveData: false),
      "lastMessage": lastMessage != null
          ? MessageModel.fromEntity(lastMessage!).toMap()
          : null,
      "unreadMessagesCount": unreadMessagesCount,
      "isPinned": isPinned,
      "isMuted": isMuted,
    };
  }

  factory ChatModel.fromJson(Map<String, dynamic> map) {
    return ChatModel(
      chatID: map["chatID"],
      receiverUser: UserModel.fromJson(map["receiverUser"]).toEntity(),
      lastMessage: map["lastMessage"] != null
          ? MessageModel.fromMap(map["lastMessage"])
          : null,
      unreadMessagesCount: map["unreadMessagesCount"],
      isPinned: map["isPinned"],
      isMuted: map["isMuted"],
      sharedKey: map["sharedKey"],
    );
  }
}
