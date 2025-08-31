// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'chat_bloc.dart';

sealed class ChatState {
  const ChatState();
}

final class ChatInitial extends ChatState {}

class CreatingChatState extends ChatState {}

class CreatingChatFailure extends ChatState {
  final Object? exception;

  CreatingChatFailure({required this.exception});
}

class CreatedChatState extends ChatState {
  final ChatEntity chat;

  CreatedChatState({required this.chat});
}

class GettingChatsState extends ChatState {}

class GotChatsState extends ChatState {
  final List<UserEntity> chats;

  const GotChatsState({
    required this.chats,
  });

  // @override
  // List<Object> get props => [chats];
}

class GettingChatsFailure extends ChatState {
  final Object exception;

  const GettingChatsFailure({required this.exception});

  // @override
  // List<Object> get props => [exception];
}

class LoadingMessages extends ChatState {}

class LoadingMessagesFailure extends ChatState {
  final Object? exception;

  LoadingMessagesFailure({required this.exception});
}

class LoadedMessages extends ChatState {
  final List<MessageEntity> messages;

  const LoadedMessages({
    required this.messages,
  });
}

class PinnedStatusToggled extends ChatState {
  final bool isPinned;

  const PinnedStatusToggled({required this.isPinned});
}

class MutedStatusToggled extends ChatState {
  final bool isMuted;

  const MutedStatusToggled({required this.isMuted});
}
