// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_cryptography_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicCryptographyModel _$PublicCryptographyModelFromJson(
        Map<String, dynamic> json) =>
    PublicCryptographyModel(
      xPublicKey: json['xPublicKey'] as String?,
      edPublicKey: json['edPublicKey'] as String?,
      pinHash: json['pinHash'] as String?,
      encryptedMnemonic: json['encryptedMnemonic'] as String?,
    );

Map<String, dynamic> _$PublicCryptographyModelToJson(
        PublicCryptographyModel instance) =>
    <String, dynamic>{
      'xPublicKey': instance.xPublicKey,
      'edPublicKey': instance.edPublicKey,
      'encryptedMnemonic': instance.encryptedMnemonic,
      'pinHash': instance.pinHash,
    };
