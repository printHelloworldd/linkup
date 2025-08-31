// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encrypted_msg_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EncryptedMsgModel _$EncryptedMsgModelFromJson(Map<String, dynamic> json) =>
    EncryptedMsgModel(
      iv: json['iv'] as String,
      tag: json['tag'] as String,
      encryptedMessage: json['encryptedMessage'] as String,
    );

Map<String, dynamic> _$EncryptedMsgModelToJson(EncryptedMsgModel instance) =>
    <String, dynamic>{
      'iv': instance.iv,
      'tag': instance.tag,
      'encryptedMessage': instance.encryptedMessage,
    };
