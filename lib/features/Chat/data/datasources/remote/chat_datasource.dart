// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/utils.dart';
import 'package:linkup/features/Chat/data/models/message_model.dart';

class ChatDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> createChatRoom(
      {required String currentUserID, required String receiverID}) async {
    final String chatRoomID =
        Utils.getChatID(currentUserID: currentUserID, otherUserID: receiverID);

    try {
      DocumentSnapshot chatRoomDoc =
          await _firestore.collection("CHAT_ROOMS").doc(chatRoomID).get();

      if (!chatRoomDoc.exists) {
        // create new chatroom in database
        await _firestore
            .collection("CHAT_ROOMS")
            .doc(chatRoomID)
            .collection("MESSAGES")
            .add({});

        // add chatroom to users doc
        await _firestore.collection("Users").doc(currentUserID).set({
          "chatrooms": {
            chatRoomID: {
              "isPinned": false,
              "isMuted": false,
            }
          }
        }, SetOptions(merge: true));

        await _firestore.collection("Users").doc(receiverID).set({
          "chatrooms": {
            chatRoomID: {
              "isPinned": false,
              "isMuted": false,
            }
          }
        }, SetOptions(merge: true));
      }

      //? Можно передавать и другие данные такие, как isMuted, и в ChatPage будет возможность поменять
      final Map<String, dynamic> chatData = {
        "chatID": chatRoomID,
      };

      return chatData;
    } catch (e) {
      if (kDebugMode) {
        print("Failed to create a chat: $e");
      }

      throw Exception(e.toString());
    }
  }

  Future<void> deleteChatRoom({
    required String chatRoomID,
    required String receiverUserID,
    required String currentUserID,
  }) async {
    final chatRoomRef = _firestore.collection("CHAT_ROOMS").doc(chatRoomID);
    final messagesRef = chatRoomRef.collection("MESSAGES");

    try {
      // Deletes all messages
      var messages = await messagesRef.get();
      for (var doc in messages.docs) {
        await doc.reference.delete();
      }

      if (kDebugMode) {
        print("Все сообщения удалены!");
      }

      // Deletes chat
      await chatRoomRef.delete();
      if (kDebugMode) {
        print("Чат успешно удален!");
      }

      // Deletes chat from users profiles
      await _firestore.collection("Users").doc(currentUserID).set({
        "chatrooms": {
          chatRoomID: FieldValue.delete(),
        }
      }, SetOptions(merge: true));

      await _firestore.collection("Users").doc(receiverUserID).set({
        "chatrooms": {
          chatRoomID: FieldValue.delete(),
        }
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print("Chat has been deleted from users profiles!");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to delete chat: $e");
      }

      throw Exception(e.toString());
    }
  }

  Future<void> setPinnedStatus(
      {required String chatID,
      required String userID,
      required bool isPinned}) async {
    try {
      final FieldPath fieldPath =
          FieldPath.fromString("chatrooms.$chatID.isPinned");

      await _firestore.collection("Users").doc(userID).set({
        "chatrooms": {
          chatID: {
            "isPinned": !isPinned,
          },
        }
      }, SetOptions(mergeFields: [fieldPath]));
    } catch (e) {
      if (kDebugMode) {
        print("Failed to pin or unpin the chat $chatID: $e");
      }

      throw Exception(e.toString());
    }
  }

  Future<void> setMutedStatus(
      {required String chatID,
      required String userID,
      required bool isMuted}) async {
    try {
      final FieldPath fieldPath =
          FieldPath.fromString("chatrooms.$chatID.isMuted");

      await _firestore.collection("Users").doc(userID).set({
        "chatrooms": {
          chatID: {
            "isMuted": !isMuted,
          },
        }
      }, SetOptions(mergeFields: [fieldPath]));
    } catch (e) {
      if (kDebugMode) {
        print("Failed to pin or unpin the chat $chatID: $e");
      }

      throw Exception(e.toString());
    }
  }

  Future<bool> isChatMuted(
      {required String chatID, required String userID}) async {
    try {
      final docSnapshot =
          await _firestore.collection("Users").doc(chatID).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final value = data?["chatrooms.$chatID.isMuted"];

        if (value is! bool) {
          throw Exception("Value Type isMuted is not bool");
        }

        return value;
      } else {
        throw Exception("Document does not exist");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //! Метод слушает весь документ пользоватеоя, а не получает чаты
  Stream<DocumentSnapshot<Map<String, dynamic>>> getAllChats(
      String currentUserID) {
    return _firestore.collection("Users").doc(currentUserID).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> messagesStream(String chatId) {
    return _firestore.collection("CHAT_ROOMS").doc(chatId).snapshots();
  }

  Future<MessageModel?> getLastMessageData(String chatRoomID) async {
    try {
      // Gets messages where the sender is not a current user
      final querySnapshot = await _firestore
          .collection("CHAT_ROOMS")
          .doc(chatRoomID)
          .collection("MESSAGES")
          .orderBy("timestamp", descending: true)
          .limit(1)
          .get();

      // Check if there is data
      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return MessageModel.fromMap(querySnapshot.docs.first.data());
    } catch (e) {
      if (kDebugMode) {
        print("Failed to get last message: $e");
      }

      throw Exception(e.toString());
    }
  }

  Future<void> sendMessage({
    required String receiverID,
    required UserEntity senderUser,
    required String message,
    // required EncryptedMsgModel encryptedMsg,
    Map<String, dynamic>? reply,
  }) async {
    // get current user info
    final String currentUserID = senderUser.id;
    final String currentUserEmail = senderUser.email;
    final Timestamp timestamp = Timestamp.now();
    // final String messageID = [timestamp, currentUserID].join("_");

    final String chatRoomID =
        Utils.getChatID(currentUserID: currentUserID, otherUserID: receiverID);

    try {
      // First, we get a link with an automatically generated ID
      DocumentReference newMessageRef = _firestore
          .collection("CHAT_ROOMS")
          .doc(chatRoomID)
          .collection("MESSAGES")
          .doc(); // Empty doc() creates a new document with an auto-generated ID

      String newMessageID = newMessageRef.id;

      // create a new message
      final MessageModel newMessage = MessageModel(
        id: newMessageID,
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: message,
        // encryptedMsg: encryptedMsg,
        timestamp: timestamp,
        reply: {
          "replyTo": reply?["replyTo"] ?? "",
          "replyMessage": reply?["replyMessage"] ?? "",
        },
        isRead: false,
      );

      // add new message to database
      await newMessageRef.set(newMessage.toMap());
    } catch (e) {
      if (kDebugMode) {
        print("Failed to send a message: $e");
      }

      throw Exception(e.toString());
    }
  }

  Future<void> deleteMessage(String receiverID, List<String> messageIDs) async {
    try {
      final String currentUserID = _auth.currentUser!.uid;
      final String chatRoomID = Utils.getChatID(
          currentUserID: currentUserID, otherUserID: receiverID);

      for (var messageID in messageIDs) {
        await _firestore
            .collection("CHAT_ROOMS")
            .doc(chatRoomID)
            .collection("MESSAGES")
            .doc(messageID)
            .delete();
      }

      if (kDebugMode) {
        print("The message has been deleted");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to delete the message: $e");
      }

      throw Exception(e.toString());
    }
  }

  Stream<List<Map<String, dynamic>>> getMessages(
      String chatID, String currentUserID) {
    // final String chatRoomID =
    //     Utils.getChatID(currentUserID: userID, otherUserID: otherUserID);

    try {
      _markMessagesAsRead(chatID, currentUserID);

      return _firestore
          .collection("CHAT_ROOMS")
          .doc(chatID)
          .collection("MESSAGES")
          .orderBy("timestamp", descending: false)
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void _markMessagesAsRead(String chatId, String currentUserID) {
    try {
      _firestore
          .collection('CHAT_ROOMS')
          .doc(chatId)
          .collection("MESSAGES")
          .where('isRead', isEqualTo: false)
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          // To prevent the sender from marking unread messages as read
          if (doc.data()["senderID"] != currentUserID) {
            doc.reference.update({'isRead': true});
          }
        }
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void markChatsAsRead(
      {required List<String> chatsIDs, required String currentUserID}) {
    try {
      for (String chatID in chatsIDs) {
        _firestore
            .collection('CHAT_ROOMS')
            .doc(chatID)
            .collection("MESSAGES")
            .where('isRead', isEqualTo: false)
            .get()
            .then((snapshot) {
          for (var doc in snapshot.docs) {
            // To prevent the sender from marking unread messages as read
            if (doc.data()["senderID"] != currentUserID) {
              doc.reference.update({'isRead': true});
            }
          }
        });
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Stream<int> getUnreadMessagesCount(String chatId, String currentUserID) {
    try {
      return _firestore
          .collection('CHAT_ROOMS')
          .doc(chatId)
          .collection("MESSAGES")
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return 0;
        }

        // We only count messages where the sender is not the current user.
        int count = 0;
        for (var doc in snapshot.docs) {
          String senderId = doc.data()["senderID"] ?? "";
          if (senderId != currentUserID) {
            count++;
          }
        }

        return count;
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
