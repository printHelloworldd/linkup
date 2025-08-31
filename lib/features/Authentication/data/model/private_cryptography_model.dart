/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:json_annotation/json_annotation.dart';
import 'package:linkup/features/Authentication/domain/entity/private_cryptography_entity.dart';

part 'private_cryptography_model.g.dart';

@JsonSerializable()
class PrivateCryptographyModel extends PrivateCryptographyEntity {
  PrivateCryptographyModel({
    super.xPrivateKey,
    super.edPrivateKey,
    super.encryptedMnemonic,
  });

  factory PrivateCryptographyModel.fromEntity(
      PrivateCryptographyEntity entity) {
    return PrivateCryptographyModel(
      xPrivateKey: entity.xPrivateKey,
      edPrivateKey: entity.edPrivateKey,
      encryptedMnemonic: entity.encryptedMnemonic,
    );
  }

  PrivateCryptographyEntity toEntity() {
    return PrivateCryptographyEntity(
      xPrivateKey: xPrivateKey,
      edPrivateKey: edPrivateKey,
      encryptedMnemonic: encryptedMnemonic,
    );
  }

  factory PrivateCryptographyModel.fromJson(Map<String, dynamic> json) =>
      _$PrivateCryptographyModelFromJson(json);

  Map<String, dynamic> toJson() => _$PrivateCryptographyModelToJson(this);
}
