import 'package:linkup/features/Chat/domain/entities/message.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required super.id,
    required super.senderID,
    required super.senderEmail,
    required super.receiverID,
    required super.message,
    // super.encryptedMsg,
    required super.timestamp,
    super.reply,
    required super.isRead,
    super.isVerified,
  });

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      senderID: senderID,
      senderEmail: senderEmail,
      receiverID: receiverID,
      message: message,
      // encryptedMsg: (encryptedMsg as EncryptedMsgModel).toEntity(),
      timestamp: timestamp,
      reply: reply,
      isRead: isRead,
      isVerified: isVerified,
    );
  }

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      senderID: entity.senderID,
      senderEmail: entity.senderEmail,
      receiverID: entity.receiverID,
      message: entity.message,
      // encryptedMsg: entity.encryptedMsg != null
      //     ? EncryptedMsgModel.fromEntity(entity.encryptedMsg!)
      //     : null,
      timestamp: entity.timestamp,
      isRead: entity.isRead,
      reply: entity.reply,
      isVerified: entity.isVerified,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "senderID": senderID,
      "senderEmail": senderEmail,
      "receiverID": receiverID,
      // "encryptedMsg": encryptedMsg != null
      //     ? EncryptedMsgModel.fromEntity(encryptedMsg!).toJson()
      //     : null,
      "message": message,
      "timestamp": timestamp,
      "reply": reply,
      "isRead": isRead,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map["id"],
      senderID: map["senderID"],
      senderEmail: map["senderEmail"],
      receiverID: map["receiverID"],
      // encryptedMsg: EncryptedMsgModel.fromJson(map["encryptedMsg"]),
      message: map["message"] ?? "***",
      timestamp: map["timestamp"],
      reply: map["reply"],
      isRead: map["isRead"] ?? false,
      isVerified: map["isVerified"] ?? false,
    );
  }
}
