import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/features/Chat/domain/entities/chat.dart';
import 'package:linkup/features/Chat/domain/entities/message.dart';
import 'package:linkup/features/Chat/domain/usecases/create_chat_room_uc.dart';
import 'package:linkup/features/Chat/domain/usecases/delete_chat_uc.dart';
import 'package:linkup/features/Chat/domain/usecases/delete_message_uc.dart';
import 'package:linkup/features/Chat/domain/usecases/get_chats_uc.dart';
import 'package:linkup/features/Chat/domain/usecases/get_messages_uc.dart';
import 'package:linkup/features/Chat/domain/usecases/mark_chats_as_read_uc.dart';
import 'package:linkup/features/Chat/domain/usecases/send_message_uc.dart';
import 'package:linkup/features/Chat/domain/usecases/set_muted_status_uc.dart';
import 'package:linkup/features/Chat/domain/usecases/set_pinned_status_uc.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final CreateChatRoomUc createChatRoomUc;
  final GetChatsUc getChatsUc;
  final SendMessageUc sendMessageUc;
  final DeleteMessageUc deleteMessageUc;
  final GetMessagesUc getMessagesUc;
  final DeleteChatUc deleteChatUc;
  final MarkChatsAsReadUc markChatsAsReadUc;
  final SetPinnedStatusUc setPinnedStatusUc;
  final SetMutedStatusUc setMutedStatusUc;

  List<UserEntity> cachedChats = [];

  ChatBloc({
    required this.createChatRoomUc,
    required this.getChatsUc,
    required this.sendMessageUc,
    required this.deleteMessageUc,
    required this.getMessagesUc,
    required this.deleteChatUc,
    required this.markChatsAsReadUc,
    required this.setMutedStatusUc,
    required this.setPinnedStatusUc,
  }) : super(ChatInitial()) {
    on<CreateChat>((event, emit) async {
      emit(CreatingChatState());

      final Either<Failure, ChatEntity> chatResult =
          await createChatRoomUc(event.receiver, event.sender);

      chatResult.fold((failure) {
        if (kDebugMode) {
          print("Failed to create a new chat: ${failure.message}");
        }

        emit(CreatingChatFailure(exception: failure));
      }, (chat) {
        emit(CreatedChatState(chat: chat));
      });
    });

    // on<GetAllChats>((event, emit) async {
    //   try {
    //     if (cachedChats.isEmpty) {
    //       emit(GettingChatsState());

    //       final chats = await getChatsUc();
    //       cachedChats = chats;

    //       emit(GotChatsState(chats: chats));
    //     }
    //   } catch (e) {
    //     emit(GettingChatsFailure(exception: e));
    //     print("Failed to get chats from Firestore: $e");
    //   }
    // });

    on<SendMessage>((event, emit) async {
      await sendMessageUc(
        receiverUser: event.receiverUser,
        chat: event.chat,
        senderUser: event.senderUser,
        message: event.message,
        reply: event.reply,
      );
    });

    on<DeleteMessage>((event, emit) async {
      await deleteMessageUc(event.receiverID, event.messageIDs);
    });

    on<GetAllMessages>((event, emit) async {
      emit(LoadingMessages());

      final Stream<Either<Failure, List<MessageEntity>>> messagesStream =
          getMessagesUc(event.currentUser, event.chatEntity);

      await emit.forEach(messagesStream, onData: (result) {
        return result.fold((failure) {
          return LoadingMessagesFailure(exception: failure);
        }, (messages) {
          return LoadedMessages(messages: messages);
        });
      });
    });

    on<DeleteChat>((event, emit) async {
      try {
        await deleteChatUc(
            chatRoomID: event.chatID,
            receiverUserID: event.receiverUserID,
            currentUserID: event.currentUserID);
      } catch (e) {
        if (kDebugMode) {
          print("Failed to delete the chat room: $e");
        }
      }
    });

    on<MarkChatsAsRead>((event, emit) {
      markChatsAsReadUc(event.chatsIDs);
    });

    on<SetPinnedStatus>((event, emit) async {
      await setPinnedStatusUc(
          chatID: event.chatID, userID: event.userID, isPinned: event.isPinned);

      emit(PinnedStatusToggled(isPinned: !event.isPinned));
    });

    on<SetMuteStatus>((event, emit) async {
      await setMutedStatusUc(
          chatID: event.chatID, userID: event.userID, isMuted: event.isMuted);

      emit(MutedStatusToggled(isMuted: !event.isMuted));
    });
  }
}
