// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:linkup/core/data/models/user/private_user_model.dart';
import 'package:linkup/core/data/models/user/restricted_user_model.dart';
import 'package:linkup/core/domain/entities/hobby_entity.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/features/Hobby/data/models/hobby_model.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.age,
    super.gender,
    required super.hobbies,
    super.country,
    super.city,
    super.profileImage,
    super.profileImageUrl,
    super.bio,
    super.socialMediaLinks,
    required super.blockedUsers,
    super.restrictedDataEntity,
    super.privateDataEntity,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      age: entity.age,
      gender: entity.gender,
      hobbies: entity.hobbies,
      country: entity.country,
      city: entity.city,
      profileImage: entity.profileImage,
      profileImageUrl: entity.profileImageUrl,
      bio: entity.bio,
      socialMediaLinks: entity.socialMediaLinks,
      blockedUsers: entity.blockedUsers,
      restrictedDataEntity: entity.restrictedDataEntity != null
          ? RestrictedUserModel.fromEntity(entity.restrictedDataEntity!)
          : null,
      privateDataEntity: entity.privateDataEntity != null
          ? PrivateUserModel.fromEntity(entity.privateDataEntity!)
          : null,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      fullName: fullName,
      age: age,
      gender: gender,
      hobbies: hobbies,
      country: country,
      city: city,
      profileImage: profileImage,
      profileImageUrl: profileImageUrl,
      bio: bio,
      socialMediaLinks: socialMediaLinks,
      blockedUsers: blockedUsers,
      restrictedDataEntity: restrictedDataEntity != null
          ? (restrictedDataEntity as RestrictedUserModel).toEntity()
          : null,
      privateDataEntity: privateDataEntity != null
          ? (privateDataEntity as PrivateUserModel).toEntity()
          : null,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map["uid"] ?? "",
      email: map["email"] ?? "",
      fullName: map["fullName"] ?? "",
      age: map["age"] ?? "",
      gender: map["gender"] ?? "",
      hobbies: List<HobbyEntity>.from(
        (map["hobbies"] as List<dynamic>)
            .map((hobby) => HobbyModel.fromJson(hobby).toEntity())
            .toList(),
      ),
      country: map["country"] ?? "",
      city: map["city"] ?? "",
      profileImage: map["profileImage"] != null
          ? Uint8List.fromList(List<int>.from(map["profileImage"]))
          : null,
      profileImageUrl: map["profileImageUrl"],
      bio: map["bio"] ?? "",
      socialMediaLinks: map["socialMediaLinks"] ?? {},
      blockedUsers: List<String>.from(map["blockedUsers"] ?? []),
      restrictedDataEntity: map["restrictedUserData"] != null
          ? RestrictedUserModel.fromJson(map["restrictedUserData"])
          : null,
      privateDataEntity: map["privateUserData"] != null
          ? PrivateUserModel.fromJson(map["privateUserData"])
          : null,
    );
  }

  Map<String, dynamic> toJson({required bool includeSensitiveData}) {
    return {
      "uid": id,
      "email": email,
      "fullName": fullName,
      "age": age,
      "gender": gender,
      "hobbies": hobbies
          .map((hobby) => HobbyModel.fromEntity(hobby).toJson())
          .toList(),
      "country": country,
      "city": city,
      "chatrooms": {},
      "profileImageUrl": profileImageUrl,
      "bio": bio,
      "socialMediaLinks": socialMediaLinks,
      "blockedUsers": blockedUsers,
      //* Null check operator is used bacause method toJson() called only to store or update user data, so this data cannot be null
      "restrictedUserData":
          RestrictedUserModel.fromEntity(restrictedDataEntity!).toJson(),
      "privateUserData": PrivateUserModel.fromEntity(privateDataEntity!)
          .toJson(includeSensitiveData: includeSensitiveData),
    };
  }
}
