import 'package:json_annotation/json_annotation.dart';
import 'package:linkup/features/Chat/domain/entities/encrypted_msg_entity.dart';

part 'encrypted_msg_model.g.dart';

@JsonSerializable()
class EncryptedMsgModel extends EncryptedMsgEntity {
  EncryptedMsgModel({
    required super.iv,
    required super.tag,
    required super.encryptedMessage,
  });

  factory EncryptedMsgModel.fromJson(Map<String, dynamic> json) =>
      _$EncryptedMsgModelFromJson(json);

  Map<String, dynamic> toJson() => _$EncryptedMsgModelToJson(this);

  EncryptedMsgEntity toEntity() =>
      EncryptedMsgEntity(iv: iv, tag: tag, encryptedMessage: encryptedMessage);

  factory EncryptedMsgModel.fromEntity(EncryptedMsgEntity entity) {
    return EncryptedMsgModel(
      iv: entity.iv,
      tag: entity.tag,
      encryptedMessage: entity.encryptedMessage,
    );
  }
}
