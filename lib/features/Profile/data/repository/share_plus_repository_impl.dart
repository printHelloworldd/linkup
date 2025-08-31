import 'package:share_plus/share_plus.dart';
import 'package:linkup/core/data/models/user/user_model.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/features/Profile/data/datasources/share_plus_datasource.dart';
import 'package:linkup/features/Profile/domain/repository/share_plus_repository.dart';

class SharePlusRepositoryImpl implements SharePlusRepository {
  final SharePlusDatasource _sharePlusDatasource;

  SharePlusRepositoryImpl(this._sharePlusDatasource);

  @override
  Future<ShareResult> shareProfile(UserEntity user) async {
    final userModel = UserModel.fromEntity(user);
    final ShareResult result =
        await _sharePlusDatasource.shareProfile(userModel);

    return result;
  }
}
