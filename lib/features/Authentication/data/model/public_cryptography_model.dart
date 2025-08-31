/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:json_annotation/json_annotation.dart';
import 'package:linkup/features/Authentication/domain/entity/public_cryptography_entity.dart';

part 'public_cryptography_model.g.dart';

@JsonSerializable()
class PublicCryptographyModel extends PublicCryptographyEntity {
  PublicCryptographyModel({
    super.xPublicKey,
    super.edPublicKey,
    super.pinHash,
    super.encryptedMnemonic,
  });

  factory PublicCryptographyModel.fromEntity(PublicCryptographyEntity entity) {
    return PublicCryptographyModel(
      xPublicKey: entity.xPublicKey,
      edPublicKey: entity.edPublicKey,
    );
  }

  PublicCryptographyEntity toEntity() {
    return PublicCryptographyEntity(
      xPublicKey: xPublicKey,
      edPublicKey: edPublicKey,
      pinHash: pinHash,
      encryptedMnemonic: encryptedMnemonic,
    );
  }

  factory PublicCryptographyModel.fromJson(Map<String, dynamic> json) =>
      _$PublicCryptographyModelFromJson(json);

  Map<String, dynamic> toJson() => _$PublicCryptographyModelToJson(this);
}
