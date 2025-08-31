import 'package:linkup/core/domain/entities/user/restricted_data_entity.dart';

class RestrictedDataFixture {
  static RestrictedDataEntity create({
    final String? fcmToken = "FCM Token",
    final String edPublicKey = "ED25519 Public Key",
    final String xPublicKey = "X25519 Public Key",
  }) {
    return RestrictedDataEntity(
        fcmToken: fcmToken, edPublicKey: edPublicKey, xPublicKey: xPublicKey);
  }
}
