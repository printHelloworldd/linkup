import 'package:flutter/material.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/entities/hobby_entity.dart';

class ProfileProvider extends ChangeNotifier {
  List<HobbyEntity> userHobbies = [];
  Map<String, String> userSocialMedias = {};

  String qrCodeData = "";
  int eteration = 0;

  void updateHobbies(List<HobbyEntity> hobbies) {
    userHobbies = hobbies;

    notifyListeners();
  }

  void updateSocialMedias(Map<String, dynamic> socialMedias) {
    userSocialMedias = Map<String, String>.from(socialMedias);

    notifyListeners();
  }

  bool checkUpdates(UserEntity userData, UserEntity newUserData) {
    return userData == newUserData;
  }

  void updateQrCodeData(String data) {
    eteration++;
    qrCodeData = data;
    notifyListeners();
  }
}
