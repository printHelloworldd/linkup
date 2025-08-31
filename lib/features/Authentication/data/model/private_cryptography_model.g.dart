// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'private_cryptography_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivateCryptographyModel _$PrivateCryptographyModelFromJson(
        Map<String, dynamic> json) =>
    PrivateCryptographyModel(
      xPrivateKey: json['xPrivateKey'] as String?,
      edPrivateKey: json['edPrivateKey'] as String?,
      encryptedMnemonic: json['encryptedMnemonic'] as String?,
    );

Map<String, dynamic> _$PrivateCryptographyModelToJson(
        PrivateCryptographyModel instance) =>
    <String, dynamic>{
      'xPrivateKey': instance.xPrivateKey,
      'edPrivateKey': instance.edPrivateKey,
      'encryptedMnemonic': instance.encryptedMnemonic,
    };
