// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageEntity {
  final String id;
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  // final EncryptedMsgEntity? encryptedMsg;
  final Timestamp timestamp;
  final Map<String, dynamic>? reply;
  final bool isRead;
  final bool? isVerified;

  MessageEntity({
    required this.id,
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    // this.encryptedMsg,
    required this.timestamp,
    required this.isRead,
    this.reply,
    this.isVerified,
  });

  MessageEntity copyWith({
    String? id,
    String? senderID,
    String? senderEmail,
    String? receiverID,
    String? message,
    Timestamp? timestamp,
    Map<String, dynamic>? reply,
    bool? isRead,
    bool? isVerified,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      senderID: senderID ?? this.senderID,
      senderEmail: senderEmail ?? this.senderEmail,
      receiverID: receiverID ?? this.receiverID,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
