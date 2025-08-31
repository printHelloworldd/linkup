import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:provider/provider.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/presentation/bloc/image%20picker/image_picker_bloc.dart';
import 'package:linkup/core/presentation/bloc/country_city/country_city_bloc.dart';
import 'package:linkup/core/presentation/widgets/custom_text_field.dart';
import 'package:linkup/features/Authentication/presentation/widgets/custom_list_wheel_scroll_view.dart';
import 'package:linkup/core/presentation/widgets/select_city_widget.dart';
import 'package:linkup/core/presentation/widgets/select_country_widget.dart';
import 'package:linkup/features/Profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:linkup/features/Profile/presentation/pages/edit_hobby_page.dart';
import 'package:linkup/features/Profile/presentation/provider/profile_provider.dart';
import 'package:linkup/features/Profile/presentation/widgets/add_social_medias_widget.dart';

class EditProfilePage extends StatefulWidget {
  final UserEntity userData;
  const EditProfilePage({
    super.key,
    required this.userData,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final UserEntity userData;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  late FixedExtentScrollController _ageController;
  late FixedExtentScrollController _genderController;

  Uint8List? profileImage;
  String? profileImageUrl;

  String _selectedAge = "";
  String _selectedGender = "";

  late FToast fToast;

  @override
  void initState() {
    super.initState();
    userData = widget.userData;

    _firstNameController.text = userData.fullName.split(" ").first;
    _secondNameController.text = userData.fullName
        .split(" ")
        .last; //! User might has more then 1 word in name or surname
    _bioController.text = userData.bio ?? "";

    profileImage = userData.profileImage;
    profileImageUrl = userData.profileImageUrl;

    context.read<CountryCityBloc>().selectedCountry = userData.country ?? "";
    context.read<CountryCityBloc>().selectedCity = userData.city ?? "";

    if (context.read<CountryCityBloc>().selectedCountry.isNotEmpty) {
      context.read<CountryCityBloc>().add(GetCountries());
    }

    Future.microtask(() {
      context.read<ProfileProvider>().updateHobbies(userData.hobbies);
    });
    Future.microtask(() {
      context
          .read<ProfileProvider>()
          .updateSocialMedias(userData.socialMediaLinks ?? {});
    });

    fToast = FToast();
    // if you want to use context from globally instead of content we need to pass navigatorKey.currentContext!
    fToast.init(context);

    _selectedAge = userData.age ?? "";
    _selectedGender = userData.gender ?? "";

    int ageInitialIndex =
        (_selectedAge == "") ? 0 : (int.parse(_selectedAge) - 13);

    int genderInitialIndex = 0;
    switch (_selectedGender) {
      case "Male":
        genderInitialIndex = 1;
        break;
      case "Female":
        genderInitialIndex = 2;
        break;
      case "Transformer":
        genderInitialIndex = 3;
        break;
    }

    _ageController = FixedExtentScrollController(initialItem: ageInitialIndex);
    _genderController =
        FixedExtentScrollController(initialItem: genderInitialIndex);
  }

  void _showFlutterWebToast() {
    FToast().showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.red[400],
        ),
        child: Text(
          context.tr("edit_profile_page.warning"),
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _showFlutterToast() {
    Fluttertoast.showToast(
      msg: context.tr("edit_profile_page.warning"),
      backgroundColor: Colors.red[400],
      fontSize: 16,
    );
  }

  void _updateUserData(BuildContext context) {
    final countryCityBloc = context.read<CountryCityBloc>();
    final userHobbies = context.read<ProfileProvider>().userHobbies;

    if (_firstNameController.text.isNotEmpty &&
        _secondNameController.text.isNotEmpty &&
        userHobbies.isNotEmpty) {
      context.read<ProfileBloc>().add(
            UpdateUserEvent(
              age: _selectedAge,
              gender: _selectedGender,
              hobbies: context.read<ProfileProvider>().userHobbies,
              fullName:
                  "${_firstNameController.text} ${_secondNameController.text}",
              bio: _bioController.text,
              profileImage: profileImage,
              country: countryCityBloc.selectedCountry,
              city: countryCityBloc.selectedCity,
              socialMediaLinks:
                  context.read<ProfileProvider>().userSocialMedias,
            ),
          );

      // // TODO: Add emit to on UpdateUserEvent
      // context
      //     .read<ProfileBloc>()
      //     .add(GetUserEvent(userID: userData.id));

      Navigator.pop(context);
    } else {
      if (kIsWeb) {
        _showFlutterWebToast();
      } else {
        _showFlutterToast();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;
    final AppColors appColors = theme.appColors;

    final countryCityBloc = context.read<CountryCityBloc>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          final UserEntity newUserData = userData.copyWith(
                            fullName:
                                "${_firstNameController.text} ${_secondNameController.text}",
                            age: _selectedAge,
                            gender: _selectedGender,
                            hobbies:
                                context.read<ProfileProvider>().userHobbies,
                            country:
                                context.read<CountryCityBloc>().selectedCountry,
                            city: context.read<CountryCityBloc>().selectedCity,
                            profileImage: profileImage,
                            bio: _bioController.text,
                            socialMediaLinks: context
                                .read<ProfileProvider>()
                                .userSocialMedias,
                          );

                          // final UserEntity newUserData = UserEntity(
                          //   id: userData.id,
                          //   email: userData.email,
                          //   fullName:
                          //       "${_firstNameController.text} ${_secondNameController.text}",
                          //   age: _selectedAge,
                          //   gender: _selectedGender,
                          //   hobbies:
                          //       context.read<ProfileProvider>().userHobbies,
                          //   country:
                          //       context.read<CountryCityBloc>().selectedCountry,
                          //   city: context.read<CountryCityBloc>().selectedCity,
                          //   profileImage: profileImage,
                          //   profileImageUrl: userData.profileImageUrl,
                          //   bio: _bioController.text,
                          //   socialMediaLinks: context
                          //       .read<ProfileProvider>()
                          //       .userSocialMedias,
                          //   // fcmToken: userData.fcmToken,
                          //   blockedUsers: userData.blockedUsers,
                          // );

                          if (kDebugMode) {
                            print(newUserData);
                            print(userData);
                          }

                          if (context
                              .read<ProfileProvider>()
                              .checkUpdates(userData, newUserData)) {
                            Navigator.pop(context);
                          } else {
                            showAdaptiveDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  // backgroundColor: AppTheme.backgroundColor,
                                  title: Text(context
                                      .tr("edit_profile_page.alert_title")),
                                  content: Text(context
                                      .tr("edit_profile_page.alert_content")),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        context.tr("core.cancel"),
                                        // style: const TextStyle(
                                        //   color: AppTheme.secondaryColor,
                                        // ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        context.tr("core.discard"),
                                        style: TextStyle(
                                          color: Colors.red[600],
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _updateUserData(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        context.tr("core.save"),
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        context.tr("settings_page.edit_profile"),
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildProfileImage(appColors, userData),
                const SizedBox(height: 16),
                CustomTextField(
                  textEditingController: _firstNameController,
                  maxLines: 1,
                  hintText: context.tr("bio_page.name"),
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  textEditingController: _secondNameController,
                  maxLines: 1,
                  hintText: context.tr("bio_page.surname"),
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  textEditingController: _bioController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  hintText: context.tr("edit_profile_page.bio"),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr("edit_profile_page.social_medias"),
                          style: TextStyle(
                            fontSize: 20,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildSocialMediasPanel(appColors),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SelectCountryWidget(
                  countries: countryCityBloc.cachedCountries,
                  userCountry: userData.country,
                ),
                const SizedBox(height: 12),
                BlocConsumer<CountryCityBloc, CountryCityState>(
                  listener: (context, state) {
                    if (state is GotCountries) {
                      final iso2 = context
                          .read<CountryCityBloc>()
                          .cachedCountries
                          .where((country) => country.name == userData.country)
                          .single
                          .iso2;

                      context
                          .read<CountryCityBloc>()
                          .add(GetCities(querry: iso2));
                    }
                  },
                  builder: (context, state) {
                    if (countryCityBloc.selectedCountry != "") {
                      return const SelectCityWidget();
                    } else {
                      return Container();
                    }
                  },
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${context.tr("profile_page.interests")} *",
                          style: TextStyle(
                            fontSize: 20,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditHobbyPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildInterestsList(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    thickness: 1.0,
                    height: 1.0,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAgeSelection(appColors),
                    _buildGenderSelection(appColors),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                  ),
                  onPressed: () {
                    _updateUserData(context);
                  },
                  child: Text(
                    context.tr("core.save"),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(AppColors appColors, UserEntity userData) {
    return Column(
      children: [
        BlocBuilder<ImagePickerBloc, ImagePickerState>(
          builder: (context, state) {
            if (state is PickedImageFromGallery) {
              profileImage = state.imageBytes;
            } else if (state is SettingImageFromGallery) {
              return const Center(
                child: SizedBox(
                  height: 64,
                  width: 64,
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return GestureDetector(
              onTap: () =>
                  context.read<ImagePickerBloc>().add(PickImageFromGallery()),
              child: profileImage != null
                  ? CircleAvatar(
                      radius: 48,
                      backgroundImage: MemoryImage(profileImage!),
                    )
                  : profileImageUrl == null
                      ? ClipOval(
                          child: Image.asset(
                            "assets/icons/user.png",
                            color: appColors.secondary,
                            width: 96,
                            height: 96,
                          ),
                        )
                      : CircleAvatar(
                          radius: 48,
                          backgroundImage: CachedNetworkImageProvider(
                            profileImageUrl!,
                          ),
                        ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          context.tr("edit_profile_page.press"),
          style: TextStyle(
            fontSize: 16,
            color: appColors.secondary,
          ),
        ),
        // IconButton(
        //   onPressed: () {
        //     setState(() {
        //       profileImage = null;
        //     });
        //   },
        //   icon: Icon(
        //     Icons.delete_outline_rounded,
        //     color: Colors.red[600],
        //   ),
        // ),
      ],
    );
  }

  Widget _buildSocialMediasPanel(AppColors appColors) {
    return Consumer<ProfileProvider>(
      builder: (context, value, child) {
        final List<String> socialMediaNames = [];
        // final List<String> socialMediaLinks = [];
        int selectedSocialMediasLength = 0;

        value.userSocialMedias.forEach((String name, String link) {
          if (link.isNotEmpty) {
            socialMediaNames.add(name);
            // socialMediaLinks.add(link);
            selectedSocialMediasLength++;
          }
        });

        if (socialMediaNames.isNotEmpty) {
          return SizedBox(
            height: 42,
            width: MediaQuery.of(context).size.width - 30,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: socialMediaNames.length,
              itemBuilder: (context, index) {
                final String socialMediaName = socialMediaNames[index];
                return Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: appColors.secondary,
                          width: 1.0,
                        ),
                      ),
                      child: Image.asset(
                        "assets/icons/logos/$socialMediaName.png",
                        width: 32,
                        color: appColors.secondary,
                      ),
                    ),
                    if (index == selectedSocialMediasLength - 1)
                      const AddSocialMediasWidget(),
                  ],
                );
              },
            ),
          );
          // return Row(
          //   children: [
          //     if (value.userSocialMedias["instagram"] != "")
          //       Padding(
          //         padding: const EdgeInsets.only(right: 12),
          //         child: Container(
          //           padding: const EdgeInsets.all(5),
          //           decoration: BoxDecoration(
          //             shape: BoxShape.circle,
          //             border: Border.all(
          //               color: AppTheme.secondaryColor,
          //               width: 1.0,
          //             ),
          //           ),
          //           child: Image.asset(
          //             "assets/icons/logos/instagram.png",
          //             width: 32,
          //             color: AppTheme.secondaryColor,
          //           ),
          //         ),
          //       ),
          //     if (value.userSocialMedias["linkedIn"] != "")
          //       Padding(
          //         padding: const EdgeInsets.only(right: 12),
          //         child: Container(
          //           padding: const EdgeInsets.all(5),
          //           decoration: BoxDecoration(
          //             shape: BoxShape.circle,
          //             border: Border.all(
          //               color: AppTheme.secondaryColor,
          //               width: 1.0,
          //             ),
          //           ),
          //           child: Image.asset(
          //             "assets/icons/logos/linkedin.png",
          //             width: 32,
          //             color: AppTheme.secondaryColor,
          //           ),
          //         ),
          //       ),
          //     if (value.userSocialMedias["youtube"] != "")
          //       Padding(
          //         padding: const EdgeInsets.only(right: 12),
          //         child: Container(
          //           padding: const EdgeInsets.all(5),
          //           decoration: BoxDecoration(
          //             shape: BoxShape.circle,
          //             border: Border.all(
          //               color: AppTheme.secondaryColor,
          //               width: 1.0,
          //             ),
          //           ),
          //           child: Image.asset(
          //             "assets/icons/logos/youtube.png",
          //             width: 32,
          //             color: AppTheme.secondaryColor,
          //           ),
          //         ),
          //       ),
          //     if (value.userSocialMedias["telegram"] != "")
          //       Padding(
          //         padding: const EdgeInsets.only(right: 12),
          //         child: Container(
          //           padding: const EdgeInsets.all(5),
          //           decoration: BoxDecoration(
          //             shape: BoxShape.circle,
          //             border: Border.all(
          //               color: AppTheme.secondaryColor,
          //               width: 1.0,
          //             ),
          //           ),
          //           child: Image.asset(
          //             "assets/icons/logos/telegram.png",
          //             width: 32,
          //             color: AppTheme.secondaryColor,
          //             scale: 0.5,
          //           ),
          //         ),
          //       ),
          //     if (value.userSocialMedias["tiktok"] != "")
          //       Padding(
          //         padding: const EdgeInsets.only(right: 12),
          //         child: Container(
          //           padding: const EdgeInsets.all(5),
          //           decoration: BoxDecoration(
          //             shape: BoxShape.circle,
          //             border: Border.all(
          //               color: AppTheme.secondaryColor,
          //               width: 1.0,
          //             ),
          //           ),
          //           child: Image.asset(
          //             "assets/icons/logos/tiktok.png",
          //             width: 32,
          //             color: AppTheme.secondaryColor,
          //           ),
          //         ),
          //       ),
          //     // Container(
          //     //   padding: const EdgeInsets.all(6),
          //     //   decoration: BoxDecoration(
          //     //     shape: BoxShape.circle,
          //     //     border: Border.all(
          //     //       color: AppTheme.secondaryColor,
          //     //       width: 1.0,
          //     //     ),
          //     //   ),
          //     //   child: Image.asset(
          //     //     "assets/icons/logos/twitter.png",
          //     //     width: 32,
          //     //     color: AppTheme.secondaryColor,
          //     //   ),
          //     // ),
          //     if (value.userSocialMedias["facebook"] != "")
          //       Padding(
          //         padding: const EdgeInsets.only(right: 12),
          //         child: Container(
          //           padding: const EdgeInsets.all(5),
          //           decoration: BoxDecoration(
          //             shape: BoxShape.circle,
          //             border: Border.all(
          //               color: AppTheme.secondaryColor,
          //               width: 1.0,
          //             ),
          //           ),
          //           child: Image.asset(
          //             "assets/icons/logos/facebook.png",
          //             width: 32,
          //             color: AppTheme.secondaryColor,
          //           ),
          //         ),
          //       ),
          //     const AddSocialMediasWidget(),
          //   ],
          // );
        } else {
          return const AddSocialMediasWidget();
        }
      },
    );
    // BlocBuilder<ProfileBloc, ProfileState>(
    //   builder: (context, state) {
    //     Map<String, dynamic> links =
    //         context.read<ProfileBloc>().cachedUserData!.socialMediaLinks!;

    //     if (links.isNotEmpty) {
    //       return Row(
    //         children: [
    //           if (links["instagram"] != "")
    //             Padding(
    //               padding: const EdgeInsets.only(right: 12),
    //               child: Container(
    //                 padding: const EdgeInsets.all(5),
    //                 decoration: BoxDecoration(
    //                   shape: BoxShape.circle,
    //                   border: Border.all(
    //                     color: AppTheme.secondaryColor,
    //                     width: 1.0,
    //                   ),
    //                 ),
    //                 child: Image.asset(
    //                   "assets/icons/logos/instagram.png",
    //                   width: 32,
    //                   color: AppTheme.secondaryColor,
    //                 ),
    //               ),
    //             ),
    //           if (links["linkedIn"] != "")
    //             Padding(
    //               padding: const EdgeInsets.only(right: 12),
    //               child: Container(
    //                 padding: const EdgeInsets.all(5),
    //                 decoration: BoxDecoration(
    //                   shape: BoxShape.circle,
    //                   border: Border.all(
    //                     color: AppTheme.secondaryColor,
    //                     width: 1.0,
    //                   ),
    //                 ),
    //                 child: Image.asset(
    //                   "assets/icons/logos/linkedin.png",
    //                   width: 32,
    //                   color: AppTheme.secondaryColor,
    //                 ),
    //               ),
    //             ),
    //           if (links["youtube"] != "")
    //             Padding(
    //               padding: const EdgeInsets.only(right: 12),
    //               child: Container(
    //                 padding: const EdgeInsets.all(5),
    //                 decoration: BoxDecoration(
    //                   shape: BoxShape.circle,
    //                   border: Border.all(
    //                     color: AppTheme.secondaryColor,
    //                     width: 1.0,
    //                   ),
    //                 ),
    //                 child: Image.asset(
    //                   "assets/icons/logos/youtube.png",
    //                   width: 32,
    //                   color: AppTheme.secondaryColor,
    //                 ),
    //               ),
    //             ),
    //           if (links["telegram"] != "")
    //             Padding(
    //               padding: const EdgeInsets.only(right: 12),
    //               child: Container(
    //                 padding: const EdgeInsets.all(5),
    //                 decoration: BoxDecoration(
    //                   shape: BoxShape.circle,
    //                   border: Border.all(
    //                     color: AppTheme.secondaryColor,
    //                     width: 1.0,
    //                   ),
    //                 ),
    //                 child: Image.asset(
    //                   "assets/icons/logos/telegram.png",
    //                   width: 32,
    //                   color: AppTheme.secondaryColor,
    //                   scale: 0.5,
    //                 ),
    //               ),
    //             ),
    //           if (links["tiktok"] != "")
    //             Padding(
    //               padding: const EdgeInsets.only(right: 12),
    //               child: Container(
    //                 padding: const EdgeInsets.all(5),
    //                 decoration: BoxDecoration(
    //                   shape: BoxShape.circle,
    //                   border: Border.all(
    //                     color: AppTheme.secondaryColor,
    //                     width: 1.0,
    //                   ),
    //                 ),
    //                 child: Image.asset(
    //                   "assets/icons/logos/tiktok.png",
    //                   width: 32,
    //                   color: AppTheme.secondaryColor,
    //                 ),
    //               ),
    //             ),
    //           // Container(
    //           //   padding: const EdgeInsets.all(6),
    //           //   decoration: BoxDecoration(
    //           //     shape: BoxShape.circle,
    //           //     border: Border.all(
    //           //       color: AppTheme.secondaryColor,
    //           //       width: 1.0,
    //           //     ),
    //           //   ),
    //           //   child: Image.asset(
    //           //     "assets/icons/logos/twitter.png",
    //           //     width: 32,
    //           //     color: AppTheme.secondaryColor,
    //           //   ),
    //           // ),
    //           if (links["facebook"] != "")
    //             Padding(
    //               padding: const EdgeInsets.only(right: 12),
    //               child: Container(
    //                 padding: const EdgeInsets.all(5),
    //                 decoration: BoxDecoration(
    //                   shape: BoxShape.circle,
    //                   border: Border.all(
    //                     color: AppTheme.secondaryColor,
    //                     width: 1.0,
    //                   ),
    //                 ),
    //                 child: Image.asset(
    //                   "assets/icons/logos/facebook.png",
    //                   width: 32,
    //                   color: AppTheme.secondaryColor,
    //                 ),
    //               ),
    //             ),
    //           const AddSocialMediasWidget(),
    //         ],
    //       );
    //     } else {
    //       return const AddSocialMediasWidget();
    //     }
    //   },
    // );
  }

  Widget _buildInterestsList() {
    return Consumer<ProfileProvider>(
      builder: (context, value, child) {
        return Text(
          value.userHobbies
              .map((hobby) => hobby.hobbyName)
              .toList()
              .join(" • "), // ?: Change seperator " • " instead of ", "
          style: const TextStyle(
            fontSize: 16,
          ),
        );
      },
    );
  }

  Widget _buildAgeSelection(AppColors appColors) {
    const int minAge = 13;
    const int maxAge = 90;

    return Row(
      children: [
        Text(
          "Age",
          style: TextStyle(
            fontSize: 18,
            color: appColors.secondary,
          ),
        ),
        const SizedBox(width: 10),
        _buildAgePicker(minAge, maxAge),
      ],
    );
  }

  Widget _buildAgePicker(int minAge, maxAge) {
    return CustomListWheelScrollView(
      controller: _ageController,
      height: 100,
      width: 50,
      onSelectedItemChanged: (index) {
        _selectedAge = index == 0 ? "" : (minAge + index).toString();
      },
      childCount: maxAge - minAge + 1,
      builder: (context, index) => _buildAgeItem(index, minAge),
    );
  }

  Widget _buildAgeItem(int index, int minAge) {
    final String age = index == 0 ? "-" : (minAge + index).toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Center(
        child: Text(
          age,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelection(AppColors appColors) {
    const List<String> genders = ["-", "Male", "Female", "Transformer"];

    return Row(
      children: [
        Text(
          "Gender",
          style: TextStyle(
            fontSize: 18,
            color: appColors.secondary,
          ),
        ),
        const SizedBox(width: 10),
        _buildGenderPicker(genders),
      ],
    );
  }

  Widget _buildGenderPicker(List<String> genders) {
    return CustomListWheelScrollView(
      controller: _genderController,
      height: 100,
      width: 120,
      onSelectedItemChanged: (index) {
        _selectedGender = genders[index];
        // if (genders[index] == "Transformer") {
        //   _playSound();
        // }
      },
      childCount: genders.length,
      builder: (context, index) => _buildGenderItem(genders[index]),
    );
  }

  Widget _buildGenderItem(String gender) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Center(
        child: Text(
          gender,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
