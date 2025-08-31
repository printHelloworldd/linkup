/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/core/domain/repository/crypto_repository.dart';

class CheckPinUc {
  final CryptoRepository cryptoRepository;

  CheckPinUc({required this.cryptoRepository});

  Future<bool> call(String data, String hash) async {
    return await cryptoRepository.isDataEqual(data, hash);
  }
}
