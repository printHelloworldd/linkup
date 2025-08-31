// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart';
import 'package:linkup/core/data/datasources/remote/firestore_datasource.dart';
import 'package:linkup/core/data/datasources/remote/supabase_datasource.dart';
import 'package:linkup/core/data/models/user/user_model.dart';

import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/core/utils.dart';
import 'package:linkup/features/Chat/data/datasources/remote/chat_datasource.dart';
import 'package:linkup/features/Chat/data/models/chat_model.dart';
import 'package:linkup/features/Chat/data/models/message_model.dart';
import 'package:linkup/features/Chat/domain/entities/chat.dart';
import 'package:linkup/features/Chat/domain/entities/message.dart';
import 'package:linkup/features/Chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatDatasource chatDatasource;
  final FirestoreDatasource firestoreDatasource;
  final SupabaseDatasource supabaseDatasource;

  ChatRepositoryImpl({
    required this.chatDatasource,
    required this.firestoreDatasource,
    required this.supabaseDatasource,
  });

  @override
  Future<Either<Failure, ChatEntity>> createChatRoom(
      String receiverID, String sharedKey, String currentUserID) async {
    try {
      final Map<String, dynamic> rawChatData = await chatDatasource
          .createChatRoom(receiverID: receiverID, currentUserID: currentUserID);

      final Map<String, dynamic>? rawReceiverUser =
          await firestoreDatasource.getUserData(receiverID, currentUserID);

      if (rawReceiverUser == null) {
        return Left(
          CommonFailure("Chat receiver user is null. ID: $receiverID"),
        );
      }

      rawChatData.addAll({"receiverUser": rawReceiverUser});

      rawChatData.addAll({"sharedKey": sharedKey});

      final ChatModel chatModel = ChatModel.fromJson(rawChatData);

      return Right(chatModel.toEntity());
    } catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<ChatEntity>>> getAllChats(
      UserEntity currentUser) {
    final String currentUserID = currentUser.id;

    return chatDatasource.getAllChats(currentUserID).switchMap((userDoc) {
      if (!userDoc.exists || !userDoc.data()!.containsKey("chatrooms")) {
        // return Stream.value(<ChatEntity>[]);
        return Stream.value(Left(CommonFailure("User document is not valid")));
      }

      final Map<dynamic, dynamic> rawChatrooms = userDoc.data()!["chatrooms"];
      final chatRooms = rawChatrooms.map(
        (key, value) => MapEntry(
          key.toString(),
          Map<String, bool>.from(value),
        ),
      );

      if (chatRooms.isEmpty) {
        return Stream.value(const Right(<ChatEntity>[]));
      }

      // Listens changes in all chats
      final chatStreams = chatRooms.entries.map((entry) {
        final String chatId = entry.key;

        // Stream for changes in messages
        Stream<DocumentSnapshot> messagesStream =
            chatDatasource.messagesStream(chatId);

        // Stream for unread messages
        Stream<int> unreadCountStream =
            chatDatasource.getUnreadMessagesCount(chatId, currentUserID);

        return CombineLatestStream.combine2(
          messagesStream,
          unreadCountStream,
          (DocumentSnapshot chatDoc, int unreadCount) => MapEntry(
            chatId,
            {
              "chatDoc": chatDoc,
              "unreadCount": unreadCount,
              'isPinned': entry.value["isPinned"],
              'isMuted': entry.value["isMuted"],
            },
          ),
        );
      });

      // Combine all chats streams
      return CombineLatestStream.list(chatStreams).asyncMap(
          (List<MapEntry<String, Map<String, dynamic>>> entries) async {
        List<ChatEntity> chats = [];

        for (var entry in entries) {
          String chatId = entry.key;
          int unreadCount = entry.value["unreadCount"];
          bool isPinned = entry.value["isPinned"];
          bool isMuted = entry.value["isMuted"];

          final String receiverID = Utils.getUserIDFromChatID(
              chatID: chatId, excludedUserID: currentUserID);

          // Gets receiver user data
          final rawData = await firestoreDatasource.getUserData(receiverID, "");
          // TODO: Поместить это в одном datasource
          final profileImage =
              await supabaseDatasource.getProfileImageUrl(rawData!["uid"]);
          rawData.addAll({"profileImageUrl": profileImage});

          final UserModel userModel = UserModel.fromJson(rawData);
          final MessageModel? lastMessageData =
              await chatDatasource.getLastMessageData(chatId);

          final ChatEntity chat = ChatModel(
            chatID: chatId,
            receiverUser: userModel,
            unreadMessagesCount: unreadCount,
            lastMessage: lastMessageData,
            isPinned: isPinned,
            isMuted: isMuted,
            sharedKey: "",
          ).toEntity();

          chats.add(chat);
        }

        return chats;
      }).handleError((error) {
        return Left(CommonFailure(error.toString()));
      }).asyncMap((value) => Right(value));
    });
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> getMessages(
      UserEntity currentUser, UserEntity otherUser, ChatEntity chat) {
    return chatDatasource
        .getMessages(chat.chatID, currentUser.id)
        .asyncMap<Either<Failure, List<MessageEntity>>>((messages) async {
      try {
        final entities = await Future.wait(
          messages.map((message) async {
            return MessageModel.fromMap(message).toEntity();
          }),
        );
        return Right(entities);
      } catch (e) {
        return Left(CommonFailure(e.toString()));
      }
    }).handleError((error) => Left(CommonFailure(error.toString())));
  }

  @override
  Future<Either<Failure, Unit>> sendMessage({
    required UserEntity receiverUser,
    required UserEntity senderUser,
    required String encryptedMessage,
    Map<String, dynamic>? reply,
    required ChatEntity chat,
  }) async {
    try {
      await chatDatasource.sendMessage(
        receiverID: receiverUser.id,
        senderUser: senderUser,
        message: encryptedMessage,
        reply: reply,
      );

      return const Right(unit);
    } catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMessage(
      String receiverID, List<String> messageIDs) async {
    try {
      await chatDatasource.deleteMessage(receiverID, messageIDs);

      return const Right(unit);
    } on Exception catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteChatRoom({
    required String chatRoomID,
    required String receiverUserID,
    required String currentUserID,
  }) async {
    try {
      await chatDatasource.deleteChatRoom(
          chatRoomID: chatRoomID,
          receiverUserID: receiverUserID,
          currentUserID: currentUserID);

      return const Right(unit);
    } on Exception catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }

  @override
  void markChatsAsRead(List<String> chatsIDs, String currentUserID) {
    chatDatasource.markChatsAsRead(
        chatsIDs: chatsIDs, currentUserID: currentUserID);
  }

  @override
  Future<Either<Failure, Unit>> setMutedStatus(
      {required String chatID,
      required String userID,
      required bool isMuted}) async {
    try {
      await chatDatasource.setMutedStatus(
          chatID: chatID, userID: userID, isMuted: isMuted);

      return const Right(unit);
    } catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> setPinnedStatus(
      {required String chatID,
      required String userID,
      required bool isPinned}) async {
    try {
      await chatDatasource.setPinnedStatus(
          chatID: chatID, userID: userID, isPinned: isPinned);

      return const Right(unit);
    } catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isChatMuted(
      {required String chatID, required String userID}) async {
    try {
      final bool isMuted =
          await chatDatasource.isChatMuted(chatID: chatID, userID: userID);
      return Right(isMuted);
    } catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }
}
