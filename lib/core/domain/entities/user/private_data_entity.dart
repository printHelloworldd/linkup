/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:equatable/equatable.dart';

class PrivateDataEntity extends Equatable {
  final String? edPrivateKey;
  final String? xPrivateKey;
  final String encryptedMnemonic;
  final String pinHash;
  final bool isVerified;

  const PrivateDataEntity({
    required this.edPrivateKey,
    required this.xPrivateKey,
    required this.encryptedMnemonic,
    required this.pinHash,
    required this.isVerified,
  });

  @override
  List<Object?> get props => [
        edPrivateKey,
        xPrivateKey,
        encryptedMnemonic,
        pinHash,
        isVerified,
      ];
}
