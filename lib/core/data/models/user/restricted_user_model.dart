/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:json_annotation/json_annotation.dart';
import 'package:linkup/core/domain/entities/user/restricted_data_entity.dart';

part 'restricted_user_model.g.dart';

@JsonSerializable()
class RestrictedUserModel extends RestrictedDataEntity {
  const RestrictedUserModel({
    super.fcmToken,
    required super.xPublicKey,
    required super.edPublicKey,
  });

  RestrictedDataEntity toEntity() {
    return RestrictedDataEntity(
      fcmToken: fcmToken,
      edPublicKey: edPublicKey,
      xPublicKey: xPublicKey,
    );
  }

  factory RestrictedUserModel.fromEntity(RestrictedDataEntity entity) {
    return RestrictedUserModel(
      fcmToken: entity.fcmToken,
      edPublicKey: entity.edPublicKey,
      xPublicKey: entity.xPublicKey,
    );
  }

  factory RestrictedUserModel.fromJson(Map<String, dynamic> json) =>
      _$RestrictedUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$RestrictedUserModelToJson(this);
}
