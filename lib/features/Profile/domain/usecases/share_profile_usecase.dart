import 'package:share_plus/share_plus.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/features/Profile/domain/repository/share_plus_repository.dart';

class ShareProfileUsecase {
  final SharePlusRepository _sharePlusRepository;

  ShareProfileUsecase(this._sharePlusRepository);

  Future<ShareResult> call(UserEntity user) async {
    return await _sharePlusRepository.shareProfile(user);
  }
}
