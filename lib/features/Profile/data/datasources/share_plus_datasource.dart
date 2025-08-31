import 'package:share_plus/share_plus.dart';
import 'package:linkup/core/data/models/user/user_model.dart';

class SharePlusDatasource {
  Future<ShareResult> shareProfile(UserModel user) async {
    String textToShare =
        "📢 Check out the profile on LinkUp! \n 👤 ${user.fullName} \n 🆔 ID: ${user.id} \n 🔗 Download the app: https://social-network-90106.web.app/";

    try {
      ShareResult result = await Share.share(textToShare);

      return result;
    } catch (e) {
      throw Exception(e);
    }
  }
}
