/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/features/Authentication/domain/entity/cryptography_entity.dart';

class PublicCryptographyEntity extends CryptographyEntity {
  PublicCryptographyEntity({
    super.xPublicKey,
    super.edPublicKey,
    super.pinHash,
    super.encryptedMnemonic,
  });
}
