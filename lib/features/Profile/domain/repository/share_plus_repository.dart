import 'package:share_plus/share_plus.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';

abstract class SharePlusRepository {
  Future<ShareResult> shareProfile(UserEntity user);
}
