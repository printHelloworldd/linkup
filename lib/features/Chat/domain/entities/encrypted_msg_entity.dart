class EncryptedMsgEntity {
  final String iv;
  final String tag;
  final String encryptedMessage;

  EncryptedMsgEntity({
    required this.iv,
    required this.tag,
    required this.encryptedMessage,
  });
}
