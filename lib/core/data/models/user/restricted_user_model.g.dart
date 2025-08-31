// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restricted_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestrictedUserModel _$RestrictedUserModelFromJson(Map<String, dynamic> json) =>
    RestrictedUserModel(
      fcmToken: json['fcmToken'] as String?,
      xPublicKey: json['xPublicKey'] as String,
      edPublicKey: json['edPublicKey'] as String,
    );

Map<String, dynamic> _$RestrictedUserModelToJson(
        RestrictedUserModel instance) =>
    <String, dynamic>{
      'fcmToken': instance.fcmToken,
      'edPublicKey': instance.edPublicKey,
      'xPublicKey': instance.xPublicKey,
    };
