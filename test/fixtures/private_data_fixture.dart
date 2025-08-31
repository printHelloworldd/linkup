import 'package:linkup/core/domain/entities/user/private_data_entity.dart';

class PrivateDataFixture {
  static PrivateDataEntity create({
    final String? edPrivateKey = "ED25519 Private Key",
    final String? xPrivateKey = "X25519 Private Key",
    final String encryptedMnemonic = "Encrypted mnemonic",
    final String pinHash = "Hashed Pin Code",
    final bool isVerified = false,
  }) {
    return PrivateDataEntity(
      edPrivateKey: edPrivateKey,
      xPrivateKey: xPrivateKey,
      encryptedMnemonic: encryptedMnemonic,
      pinHash: pinHash,
      isVerified: isVerified,
    );
  }
}
