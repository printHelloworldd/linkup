// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'private_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivateUserModel _$PrivateUserModelFromJson(Map<String, dynamic> json) =>
    PrivateUserModel(
      edPrivateKey: json['edPrivateKey'] as String?,
      xPrivateKey: json['xPrivateKey'] as String?,
      encryptedMnemonic: json['encryptedMnemonic'] as String,
      pinHash: json['pinHash'] as String,
      isVerified: json['isVerified'] as bool,
    );

Map<String, dynamic> _$PrivateUserModelToJson(PrivateUserModel instance) =>
    <String, dynamic>{
      'edPrivateKey': instance.edPrivateKey,
      'xPrivateKey': instance.xPrivateKey,
      'encryptedMnemonic': instance.encryptedMnemonic,
      'pinHash': instance.pinHash,
      'isVerified': instance.isVerified,
    };
