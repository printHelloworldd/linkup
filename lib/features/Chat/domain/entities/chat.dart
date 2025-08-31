// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/features/Chat/domain/entities/message.dart';

class ChatEntity {
  final String chatID;
  final UserEntity receiverUser;
  final MessageEntity? lastMessage;
  final int? unreadMessagesCount;
  final bool? isPinned;
  final bool? isMuted;
  final String sharedKey;

  ChatEntity({
    required this.chatID,
    required this.receiverUser,
    this.lastMessage,
    this.unreadMessagesCount,
    this.isPinned,
    this.isMuted,
    required this.sharedKey,
  });

  ChatEntity copyWith({
    String? chatID,
    UserEntity? receiverUser,
    MessageEntity? lastMessage,
    int? unreadMessagesCount,
    bool? isPinned,
    bool? isMuted,
    String? sharedKey,
  }) {
    return ChatEntity(
      chatID: chatID ?? this.chatID,
      receiverUser: receiverUser ?? this.receiverUser,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadMessagesCount: unreadMessagesCount ?? this.unreadMessagesCount,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      sharedKey: sharedKey ?? this.sharedKey,
    );
  }
}
