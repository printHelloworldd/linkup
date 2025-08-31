/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:equatable/equatable.dart';

import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:linkup/core/data/models/user/private_user_model.dart';
import 'package:linkup/core/data/models/user/restricted_user_model.dart';
import 'package:linkup/core/domain/entities/hobby_entity.dart';
import 'package:linkup/core/domain/entities/user/private_data_entity.dart';
import 'package:linkup/core/domain/entities/user/restricted_data_entity.dart';

const _deepEq = DeepCollectionEquality();
const _bytesEq = ListEquality<int>();
const _listStrEq = ListEquality<String>();

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? age;
  final String? gender;
  final List<HobbyEntity> hobbies;
  final String? country;
  final String? city;
  final Uint8List? profileImage;
  final String? profileImageUrl;
  final String? bio;
  final Map<String, dynamic>? socialMediaLinks;
  final List<String> blockedUsers;
  final RestrictedDataEntity? restrictedDataEntity;
  final PrivateDataEntity? privateDataEntity;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.age,
    this.gender,
    required this.hobbies,
    this.country,
    this.city,
    this.profileImage,
    this.profileImageUrl,
    this.bio,
    this.socialMediaLinks,
    required this.blockedUsers,
    this.restrictedDataEntity,
    this.privateDataEntity,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        age,
        gender,
        _deepEq.hash(hobbies),
        country,
        city,
        profileImageUrl,
        bio,
        _deepEq.hash(socialMediaLinks),
        _listStrEq.hash(blockedUsers),
        RestrictedDataEntity,
        PrivateDataEntity,
        profileImage == null ? null : _bytesEq.hash(profileImage),
      ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? age,
    String? gender,
    List<HobbyEntity>? hobbies,
    String? country,
    String? city,
    Uint8List? profileImage,
    String? profileImageUrl,
    String? bio,
    Map<String, dynamic>? socialMediaLinks,
    List<String>? blockedUsers,
    RestrictedDataEntity? restrictedDataEntity,
    PrivateDataEntity? privateDataEntity,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      hobbies: hobbies ?? this.hobbies,
      country: country ?? this.country,
      city: city ?? this.city,
      profileImage: profileImage ?? this.profileImage,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      socialMediaLinks: socialMediaLinks ?? this.socialMediaLinks,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      restrictedDataEntity: restrictedDataEntity ?? this.restrictedDataEntity,
      privateDataEntity: privateDataEntity ?? this.privateDataEntity,
    );
  }

  static bool isPrivateDataEmpty(PrivateDataEntity? entity) {
    if (entity == null) return true;

    final Map<String, dynamic> privateData =
        PrivateUserModel.fromEntity(entity).toJson(includeSensitiveData: true);

    return privateData.values.any((value) {
      if (value == null) return true;
      if (value is String && value.trim().isEmpty) return true;

      return false;
    });
  }

  static bool isRestrictedDataEmpty(RestrictedDataEntity? entity) {
    if (entity == null) return true;

    final Map<String, dynamic> restrictedData =
        RestrictedUserModel.fromEntity(entity).toJson();

    return restrictedData.values.any((value) {
      if (value == null) return true;
      if (value is String && value.trim().isEmpty) return true;

      return false;
    });
  }
}
