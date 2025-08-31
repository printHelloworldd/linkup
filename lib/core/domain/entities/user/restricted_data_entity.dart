/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:equatable/equatable.dart';

class RestrictedDataEntity extends Equatable {
  final String? fcmToken;
  final String edPublicKey;
  final String xPublicKey;

  const RestrictedDataEntity({
    this.fcmToken,
    required this.edPublicKey,
    required this.xPublicKey,
  });

  @override
  List<Object?> get props => [
        fcmToken,
        edPublicKey,
        xPublicKey,
      ];
}
