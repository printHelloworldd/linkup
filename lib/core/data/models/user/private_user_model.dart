/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:json_annotation/json_annotation.dart';
import 'package:linkup/core/domain/entities/user/private_data_entity.dart';

part 'private_user_model.g.dart';

@JsonSerializable()
class PrivateUserModel extends PrivateDataEntity {
  const PrivateUserModel({
    super.edPrivateKey,
    super.xPrivateKey,
    required super.encryptedMnemonic,
    required super.pinHash,
    required super.isVerified,
  });

  PrivateDataEntity toEntity() {
    return PrivateDataEntity(
      edPrivateKey: edPrivateKey,
      xPrivateKey: xPrivateKey,
      encryptedMnemonic: encryptedMnemonic,
      pinHash: pinHash,
      isVerified: isVerified,
    );
  }

  factory PrivateUserModel.fromEntity(PrivateDataEntity entity) {
    return PrivateUserModel(
      edPrivateKey: entity.edPrivateKey,
      xPrivateKey: entity.xPrivateKey,
      encryptedMnemonic: entity.encryptedMnemonic,
      pinHash: entity.pinHash,
      isVerified: entity.isVerified,
    );
  }

  factory PrivateUserModel.fromJson(Map<String, dynamic> json) =>
      _$PrivateUserModelFromJson(json);

  Map<String, dynamic> toJson({required bool includeSensitiveData}) {
    final json = _$PrivateUserModelToJson(this);

    if (!includeSensitiveData) {
      json.remove("edPrivateKey");
      json.remove("xPrivateKey");
    }

    return json;
  }
}
