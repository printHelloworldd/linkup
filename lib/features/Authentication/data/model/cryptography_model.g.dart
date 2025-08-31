// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cryptography_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CryptographyModel _$CryptographyModelFromJson(Map<String, dynamic> json) =>
    CryptographyModel(
      xPrivateKey: json['xPrivateKey'] as String?,
      xPublicKey: json['xPublicKey'] as String?,
      edPrivateKey: json['edPrivateKey'] as String?,
      edPublicKey: json['edPublicKey'] as String?,
      encryptedMnemonic: json['encryptedMnemonic'] as String?,
      pinHash: json['pinHash'] as String?,
    );

Map<String, dynamic> _$CryptographyModelToJson(CryptographyModel instance) =>
    <String, dynamic>{
      'xPrivateKey': instance.xPrivateKey,
      'xPublicKey': instance.xPublicKey,
      'edPrivateKey': instance.edPrivateKey,
      'edPublicKey': instance.edPublicKey,
      'encryptedMnemonic': instance.encryptedMnemonic,
      'pinHash': instance.pinHash,
    };
