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
import 'package:linkup/features/Chat/presentation/bloc/chat_bloc.dart';
import 'package:linkup/features/Chat/presentation/pages/chat_page.dart';
import 'package:linkup/features/Profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:linkup/features/Profile/presentation/bloc/share_plus/share_plus_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfilePage extends StatefulWidget {
  final UserEntity user;
  final bool navigatedFromChatPage;

  const UserProfilePage({
    super.key,
    required this.user,
    required this.navigatedFromChatPage,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    // if you want to use context from globally instead of content we need to pass navigatorKey.currentContext!
    fToast.init(context);
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

    final UserEntity user = widget.user;
    final profileImage = user.profileImage;
    final profileImageUrl = user.profileImageUrl;
    final List<String> userHobbyNames =
        user.hobbies.map((hobby) => hobby.hobbyName).toList();

    String displayedLocation = "";
    if (user.city == "") {
      displayedLocation = user.country!;
    } else if (user.city != "" && user.country == "") {
      displayedLocation = user.city!;
    } else {
      displayedLocation = "${user.city}, ${user.country}";
    }

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
        } else if (state is SharingProfileDismissed) {
          String msg = context.tr("profile_page.canceled");
          Color backgroundColor = Colors.yellow[600]!;
          Color textColor = appColors.background;

          if (!kIsWeb) {
            _showToast(msg, backgroundColor, textColor);
          } else {
            _showWebToast(msg, backgroundColor, textColor);
          }
        } else if (state is SharingProfileFailure) {
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
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),

              _buildAppBar(user),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    _buildProfileImage(
                        appColors, profileImage, profileImageUrl),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            softWrap: true,
                          ),
                        ),
                        if (!widget.navigatedFromChatPage)
                          BlocConsumer<ChatBloc, ChatState>(
                            listener: (context, state) {
                              if (state is CreatedChatState) {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ChatPage(
                                    chatEntity: state.chat,
                                  );
                                }));
                              } else if (state is CreatingChatFailure) {
                                if (kIsWeb) {
                                  _showWebToast("Failed to create a chat",
                                      Colors.red[600]!, appColors.background);
                                } else {
                                  _showToast("Failed to create a chat",
                                      Colors.red[600]!, appColors.background);
                                }
                              }
                            },
                            builder: (context, state) {
                              if (state is CreatingChatState) {
                                return const SizedBox(
                                  height: 32,
                                  width: 32,
                                  child: CircularProgressIndicator(),
                                );
                              }

                              return IconButton(
                                onPressed: () {
                                  final UserEntity currentUser = context
                                      .read<ProfileBloc>()
                                      .cachedUserData!;

                                  context.read<ChatBloc>().add(
                                        CreateChat(
                                            receiver: user,
                                            sender: currentUser),
                                      );
                                },
                                icon: Icon(
                                  Icons.chat_rounded,
                                  size: 32,
                                  color: appColors.primary,
                                ),
                              );
                            },
                          ),
                      ],
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
                    if (user.age != "-" && user.age!.isNotEmpty)
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
                    _buildSocialMediaPanel(appColors, user),
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
              //     indicatorColor: AppTheme.primaryColor,
              //     labelColor: AppTheme.primaryColor,
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
                // child: ClipOval(
                //   child: CachedNetworkImage(
                //     imageUrl: profileImageUrl,
                //     width: 94,
                //     height: 94,
                //     fit: BoxFit.fill,
                //     placeholder: (context, url) =>
                //         const CircularProgressIndicator(
                //       color: AppTheme.primaryColor,
                //     ),
                //     errorWidget: (context, url, error) =>
                //         const Icon(Icons.error),
                //   ),
                // ),
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
            child: ClipOval(
              child: Image.memory(
                profileImage,
                width: 94,
                height: 94,
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

  Widget _buildSocialMediaPanel(AppColors appColors, UserEntity user) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        Map<String, dynamic> links = user.socialMediaLinks!;

        if (links.isNotEmpty) {
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
          return Container();
        }
      },
    );
  }

  Widget _buildAppBar(UserEntity user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
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
              // const SizedBox(width: 8),
              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(Icons.more_horiz),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
