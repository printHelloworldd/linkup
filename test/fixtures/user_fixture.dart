import 'package:linkup/core/domain/entities/hobby_entity.dart';
import 'package:linkup/core/domain/entities/user/private_data_entity.dart';
import 'package:linkup/core/domain/entities/user/restricted_data_entity.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';

import 'private_data_fixture.dart';
import 'restricted_data_fixture.dart';

class UserFixture {
  static UserEntity create({
    final String id = "id",
    final String email = "email",
    final String fullName = "Full name",
    final String? age = "18",
    final String? gender = "Transformer",
    final List<HobbyEntity> hobbies = const [],
    final String? country = "Country",
    final String? city = "City",
    final String? profileImageUrl = "url",
    final String? bio = "About me",
    final Map<String, dynamic>? socialMediaLinks = const {},
    final List<String> blockedUsers = const [],
    final RestrictedDataEntity? restrictedDataEntity,
    final PrivateDataEntity? privateDataEntity,
  }) {
    return UserEntity(
      id: id,
      email: email,
      fullName: fullName,
      age: age,
      gender: gender,
      hobbies: hobbies,
      country: country,
      city: city,
      profileImageUrl: profileImageUrl,
      bio: bio,
      socialMediaLinks: socialMediaLinks,
      blockedUsers: blockedUsers,
      restrictedDataEntity:
          restrictedDataEntity ?? RestrictedDataFixture.create(),
      privateDataEntity: privateDataEntity ?? PrivateDataFixture.create(),
    );
  }
}
