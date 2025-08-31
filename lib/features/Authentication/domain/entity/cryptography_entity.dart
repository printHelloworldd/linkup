/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

class CryptographyEntity {
  final String? xPrivateKey;
  final String? xPublicKey;
  final String? edPrivateKey;
  final String? edPublicKey;
  final String? encryptedMnemonic;
  final String? pinHash;

  CryptographyEntity({
    this.xPrivateKey,
    this.xPublicKey,
    this.edPrivateKey,
    this.edPublicKey,
    this.encryptedMnemonic,
    this.pinHash,
  });
}
