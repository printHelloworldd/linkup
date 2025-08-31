// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetUserEvent extends ProfileEvent {
  final String userID;

  const GetUserEvent({
    required this.userID,
  });

  @override
  List<Object?> get props => [userID];
}

class GetUserFromFirestoreEvent extends ProfileEvent {
  final String userID;

  const GetUserFromFirestoreEvent({
    required this.userID,
  });

  @override
  List<Object?> get props => [userID];
}

class UpdateUserEvent extends ProfileEvent {
  final String? id;
  final String? email;
  final String? fullName;
  final String? age;
  final String? gender;
  final List<HobbyEntity>? hobbies;
  final String? country;
  final String? city;
  final Uint8List? profileImage;
  final String? profileImageUrl;
  final String? bio;
  final Map<String, dynamic>? socialMediaLinks;
  // final String? privateKey;
  final String? blockedUser;
  final PrivateDataEntity? privateDataEntity;
  final RestrictedDataEntity? restrictedDataEntity;
  final CryptographyEntity? cryptographyEntity;

  const UpdateUserEvent({
    this.id,
    this.email,
    this.fullName,
    this.age,
    this.gender,
    this.hobbies,
    this.country,
    this.city,
    this.profileImage,
    this.profileImageUrl,
    this.bio,
    this.socialMediaLinks,
    // this.privateKey,
    this.blockedUser,
    this.privateDataEntity,
    this.restrictedDataEntity,
    this.cryptographyEntity,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        age,
        gender,
        hobbies,
        country,
        city,
        profileImage,
        bio,
        socialMediaLinks,
        // privateKey,
        blockedUser,
        PrivateDataEntity,
        RestrictedDataEntity,
        cryptographyEntity,
      ];
}
