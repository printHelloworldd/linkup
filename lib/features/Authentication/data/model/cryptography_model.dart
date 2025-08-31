/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:json_annotation/json_annotation.dart';
import 'package:linkup/features/Authentication/domain/entity/cryptography_entity.dart';

part 'cryptography_model.g.dart';

@JsonSerializable()
class CryptographyModel extends CryptographyEntity {
  CryptographyModel({
    required super.xPrivateKey,
    required super.xPublicKey,
    required super.edPrivateKey,
    required super.edPublicKey,
    required super.encryptedMnemonic,
    required super.pinHash,
  });

  factory CryptographyModel.fromEntity(CryptographyEntity entity) {
    return CryptographyModel(
      xPrivateKey: entity.xPrivateKey,
      xPublicKey: entity.xPublicKey,
      edPrivateKey: entity.edPrivateKey,
      edPublicKey: entity.edPublicKey,
      encryptedMnemonic: entity.encryptedMnemonic,
      pinHash: entity.pinHash,
    );
  }

  CryptographyEntity toEntity() {
    return CryptographyEntity(
        xPrivateKey: xPrivateKey,
        xPublicKey: xPublicKey,
        edPrivateKey: edPrivateKey,
        edPublicKey: edPublicKey,
        encryptedMnemonic: encryptedMnemonic,
        pinHash: pinHash);
  }

  factory CryptographyModel.fromJson(Map<String, dynamic> json) =>
      _$CryptographyModelFromJson(json);

  Map<String, dynamic> toJson() => _$CryptographyModelToJson(this);
}
