// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class CreateChat extends ChatEvent {
  final UserEntity receiver;
  final UserEntity sender;

  const CreateChat({
    required this.receiver,
    required this.sender,
  });

  // @override
  // List<Object> get props => [re];
}

class GetAllChats extends ChatEvent {}

class GetAllMessages extends ChatEvent {
  final UserEntity currentUser;
  final UserEntity otherUser;
  final ChatEntity chatEntity;

  const GetAllMessages({
    required this.currentUser,
    required this.otherUser,
    required this.chatEntity,
  });
}

class SendMessage extends ChatEvent {
  final UserEntity receiverUser;
  final UserEntity senderUser;
  final String message;
  final ChatEntity chat;
  final Map<String, dynamic>? reply;
  final String senderName;
  final String? receiverFCMToken;

  const SendMessage({
    required this.receiverUser,
    required this.senderUser,
    required this.message,
    required this.chat,
    this.reply,
    required this.senderName,
    this.receiverFCMToken,
  });
}

class DeleteMessage extends ChatEvent {
  final String receiverID;
  final List<String> messageIDs;

  const DeleteMessage({
    required this.receiverID,
    required this.messageIDs,
  });
}

class DeleteChat extends ChatEvent {
  final String chatID;
  final String receiverUserID;
  final String currentUserID;

  const DeleteChat({
    required this.chatID,
    required this.receiverUserID,
    required this.currentUserID,
  });
}

class MarkChatsAsRead extends ChatEvent {
  final List<String> chatsIDs;

  const MarkChatsAsRead({required this.chatsIDs});
}

class SetPinnedStatus extends ChatEvent {
  final bool isPinned;
  final String userID;
  final String chatID;

  const SetPinnedStatus({
    required this.isPinned,
    required this.userID,
    required this.chatID,
  });
}

class SetMuteStatus extends ChatEvent {
  final bool isMuted;
  final String userID;
  final String chatID;

  const SetMuteStatus({
    required this.isMuted,
    required this.userID,
    required this.chatID,
  });
}
