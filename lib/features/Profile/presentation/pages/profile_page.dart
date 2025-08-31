import 'package:cached_network_image/cached_network_image.dart';
import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/config/theme/theme_getter.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/features/Profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:linkup/features/Profile/presentation/bloc/share_plus/share_plus_bloc.dart';
import 'package:linkup/features/Profile/presentation/pages/settings_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late FToast fToast;
  late bool isUserVerified;

  @override
  void initState() {
    // context.read<ProfileBloc>().add(GetUserEvent());

    //* Has user generated seed phrase, if he has the user is considered as verified
    isUserVerified = context
            .read<ProfileBloc>()
            .cachedUserData
            ?.privateDataEntity
            ?.isVerified ??
        false;

    fToast = FToast();
    // if you want to use context from globally instead of content we need to pass navigatorKey.currentContext!
    fToast.init(context);
    super.initState();
  }

  Future<void> _openLinkInAppWebView(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch ${Uri.parse(url)}');
    }
  }

  void _showToast(String msg, Color backgroundColor, textColor) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: backgroundColor,
      fontSize: 16,
      textColor: textColor,
    );
  }

  void _showWebToast(String msg, Color backgroundColor, textColor) {
    FToast().showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: backgroundColor,
        ),
        child: Text(
          msg,
          style: TextStyle(
            fontSize: 16,
            color: textColor,
          ),
        ),
      ),
    );
  }

  final List<TabData> tabs = [
    TabData(
      index: 0,
      title: const Tab(
        child: Text('Posts'),
      ),
      content: const Center(child: Text('Content for Tab 1')),
    ),
    TabData(
      index: 1,
      title: const Tab(
        child: Text('Groups'),
      ),
      content: const Center(child: Text('Content for Tab 2')),
    ),
    // Add more tabs as needed
  ];

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return BlocListener<SharePlusBloc, SharePlusState>(
      listener: (context, state) {
        if (state is SharingProfileSuccess) {
          String msg = context.tr("profile_page.shared");
          Color backgroundColor = Colors.green[600]!;
          Color textColor = appColors.secondary;

          if (!kIsWeb) {
            _showToast(msg, backgroundColor, textColor);
          } else {
            _showWebToast(msg, backgroundColor, textColor);
          }
        }
        // else if (state is SharingProfileDismissed) {
        //   const String msg = '❌ You have cancelled your profile sharing.';
        //   Color backgroundColor = Colors.yellow[600]!;
        //   Color textColor = appColors.background;

        //   _showToast(msg, backgroundColor, textColor);
        // }
        else if (state is SharingProfileFailure) {
          String msg = context.tr("profile_page.failed");
          Color backgroundColor = Colors.red[600]!;
          Color textColor = appColors.background;

          if (!kIsWeb) {
            _showToast(msg, backgroundColor, textColor);
          } else {
            _showWebToast(msg, backgroundColor, textColor);
          }
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is GettingUserState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is GettingUserFailureState) {
            return const Center(
              child: Text("Something went wrong :( \n Try again later"),
            );
          } else if (state is GotUserState) {
            final UserEntity user = state.user!;
            final profileImage = user.profileImage;
            final profileImageUrl = user.profileImageUrl;
            final List<String> userHobbyNames =
                state.user!.hobbies.map((hobby) => hobby.hobbyName).toList();

            String displayedLocation = "";
            if (user.city == "") {
              displayedLocation = user.country!;
            } else if (user.city != "" && user.country == "") {
              displayedLocation = user.city!;
            } else {
              displayedLocation = "${user.city}, ${user.country}";
            }

            return Scaffold(
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 64),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildProfileImage(
                                  appColors, profileImage, profileImageUrl),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      context
                                          .read<SharePlusBloc>()
                                          .add(ShareProfileEvent(user: user));
                                    },
                                    icon: const FaIcon(FontAwesomeIcons.share),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      // Navigator.pushNamed(
                                      //   context,
                                      //   "/settings_page",
                                      //   arguments: {"user": user},
                                      // );
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return SettingsPage(userData: user);
                                      }));
                                    },
                                    icon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!isUserVerified)
                                          Container(
                                            height: 6,
                                            width: 6,
                                            margin:
                                                const EdgeInsets.only(right: 6),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: appColors.primary,
                                            ),
                                          ),
                                        const Icon(Icons.more_horiz),
                                      ],
                                    ),
                                  ),
                                  // TextButton.icon(
                                  //   onPressed: () {
                                  //     Wiredash.of(context)
                                  //         .show(inheritMaterialTheme: true);
                                  //   },
                                  //   label: Text(
                                  //     "Report",
                                  //     style: TextStyle(
                                  //       color: Colors.red[600],
                                  //     ),
                                  //   ),
                                  //   icon: Icon(
                                  //     Icons.bug_report_outlined,
                                  //     color: Colors.red[600],
                                  //   ),
                                  //   iconAlignment: IconAlignment.end,
                                  // ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 4, // Отступ между элементами
                            runSpacing: 4, // Отступ между строками
                            children: [
                              Text(
                                context.tr("profile_page.interests"),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                userHobbyNames.join(", "),
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          _buildLocationInfo(user, displayedLocation),
                          const SizedBox(height: 5),
                          if (user.bio != "")
                            Wrap(
                              alignment: WrapAlignment.start,
                              spacing: 4, // Отступ между элементами
                              runSpacing: 4, // Отступ между строками
                              children: [
                                Text(
                                  context.tr("profile_page.bio"),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(user.bio!),
                              ],
                            ),
                          const SizedBox(height: 5),
                          if (user.age != null || user.age != "")
                            Row(
                              children: [
                                Text(
                                  context.tr("profile_page.age"),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user.age!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 15),
                          _buildSocialMediaPanel(appColors),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 20),
                    // Expanded(
                    //   child: DynamicTabBarWidget(
                    //     dynamicTabs: tabs,
                    //     isScrollable: false,
                    //     onTabControllerUpdated: (controller) {},
                    //     onTabChanged: (index) {},
                    //     indicatorColor: appColors.primary,
                    //     labelColor: appColors.primary,
                    //     labelStyle: const TextStyle(
                    //       fontSize: 18,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //     unselectedLabelColor: Colors.grey[500],
                    //     unselectedLabelStyle: const TextStyle(
                    //       fontSize: 16,
                    //     ),
                    //     // onAddTabMoveTo: MoveToTab.last,
                    //   ),
                    // ),
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget _buildProfileImage(
      AppColors appColors, Uint8List? profileImage, String? profileImageUrl) {
    return profileImage == null
        ? profileImageUrl == null
            ? Image.asset(
                "assets/icons/user.png",
                width: 94,
                height: 94,
                color: appColors.secondary,
              )
            : Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appColors.secondary,
                    width: 1.0,
                  ),
                ),
                child: CircleAvatar(
                  radius: 47,
                  backgroundImage: CachedNetworkImageProvider(
                    profileImageUrl,
                  ),
                ),
              )
        : Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: appColors.secondary,
                width: 1.0,
              ),
            ),
            child: CircleAvatar(
              radius: 47,
              backgroundImage: MemoryImage(
                profileImage,
              ),
            ),
          );
  }

  Widget _buildLocationInfo(UserEntity user, String displayedLocation) {
    if (user.country != "" || user.city != "") {
      return Row(
        children: [
          Text(
            context.tr("profile_page.location"),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            displayedLocation,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      );
    }
    return Container();
  }

  Widget _buildSocialMediaPanel(AppColors appColors) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        Map<String, dynamic> links =
            context.read<ProfileBloc>().cachedUserData!.socialMediaLinks!;

        if (links.values.any((value) => value.isNotEmpty)) {
          return Row(
            children: [
              if (links["instagram"] != "")
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () async {
                      await _openLinkInAppWebView(links["instagram"]!);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: appColors.secondary,
                          width: 1.0,
                        ),
                      ),
                      child: Image.asset(
                        "assets/icons/logos/instagram.png",
                        width: 32,
                        color: appColors.secondary,
                      ),
                    ),
                  ),
                ),
              if (links["linkedIn"] != "")
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () async {
                      await _openLinkInAppWebView(links["linkedIn"]!);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: appColors.secondary,
                          width: 1.0,
                        ),
                      ),
                      child: Image.asset(
                        "assets/icons/logos/linkedIn.png",
                        width: 32,
                        color: appColors.secondary,
                      ),
                    ),
                  ),
                ),
              if (links["youtube"] != "")
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () async {
                      await _openLinkInAppWebView(links["youtube"]!);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: appColors.secondary,
                          width: 1.0,
                        ),
                      ),
                      child: Image.asset(
                        "assets/icons/logos/youtube.png",
                        width: 32,
                        color: appColors.secondary,
                      ),
                    ),
                  ),
                ),
              if (links["telegram"] != "")
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () async {
                      await _openLinkInAppWebView(links["telegram"]!);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: appColors.secondary,
                          width: 1.0,
                        ),
                      ),
                      child: Image.asset(
                        "assets/icons/logos/telegram.png",
                        width: 32,
                        color: appColors.secondary,
                        scale: 0.5,
                      ),
                    ),
                  ),
                ),
              if (links["tiktok"] != "")
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () async {
                      await _openLinkInAppWebView(links["tiktok"]!);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: appColors.secondary,
                          width: 1.0,
                        ),
                      ),
                      child: Image.asset(
                        "assets/icons/logos/tiktok.png",
                        width: 32,
                        color: appColors.secondary,
                      ),
                    ),
                  ),
                ),
              // Container(
              //   padding: const EdgeInsets.all(6),
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     border: Border.all(
              //       color: appColors.secondary,
              //       width: 1.0,
              //     ),
              //   ),
              //   child: Image.asset(
              //     "assets/icons/logos/twitter.png",
              //     width: 32,
              //     color: appColors.secondary,
              //   ),
              // ),
              if (links["facebook"] != "")
                GestureDetector(
                  onTap: () async {
                    await _openLinkInAppWebView(links["facebook"]!);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: appColors.secondary,
                        width: 1.0,
                      ),
                    ),
                    child: Image.asset(
                      "assets/icons/logos/facebook.png",
                      width: 32,
                      color: appColors.secondary,
                    ),
                  ),
                ),
            ],
          );
        } else {
          // return Container();

          return Text(
            context.tr("profile_page.add"),
            style: TextStyle(
              color: appColors.hint,
            ),
          );

          // return const AddSocialMediasWidget();

          // return TextButton.icon(
          //   onPressed: () {},
          //   label: const Text(
          //     "Add",
          //     style: TextStyle(
          //       color: appColors.primary,
          //     ),
          //   ),
          //   // iconAlignment: IconAlignment.end,
          //   icon: const Icon(
          //     MingCuteIcons.mgc_add_line,
          //     color: appColors.primary,
          //     size: 16,
          //   ),
          // );
        }
      },
    );
  }
}
