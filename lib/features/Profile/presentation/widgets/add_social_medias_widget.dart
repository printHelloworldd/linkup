// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:provider/provider.dart';

import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/config/theme/theme_getter.dart';
import 'package:linkup/core/presentation/widgets/popup%20card/custom_rect_tween.dart';
import 'package:linkup/core/presentation/widgets/popup%20card/hero_dialog_route.dart';
import 'package:linkup/features/Profile/presentation/provider/profile_provider.dart';

class AddSocialMediasWidget extends StatelessWidget {
  // final UserEntity userData;

  const AddSocialMediasWidget({
    super.key,
    // required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: _hero,
      createRectTween: (begin, end) {
        return CustomRectTween(begin: begin!, end: end!);
      },
      child: IconButton(
        onPressed: () {
          Navigator.of(context).push(HeroDialogRoute(builder: (context) {
            return const _AddSocialMediasWidget();
          }));
        },
        icon: const Icon(Icons.edit_outlined),
      ),
    );
  }
}

const String _hero = 'add-social-media-hero';

class _AddSocialMediasWidget extends StatefulWidget {
  const _AddSocialMediasWidget();
  @override
  State<_AddSocialMediasWidget> createState() => _AddSocialMediasWidgetState();
}

class _AddSocialMediasWidgetState extends State<_AddSocialMediasWidget> {
  // late final UserEntity userData;

  // Создание маппинга для полей
  final Map<String, TextEditingController> _controllers = {
    'instagram': TextEditingController(),
    'linkedIn': TextEditingController(),
    'youtube': TextEditingController(),
    'telegram': TextEditingController(),
    'tiktok': TextEditingController(),
    'facebook': TextEditingController(),
  };

// Функция для обновления значений
  void _updateControllers(Map<String, dynamic> socialMediaLinks) {
    socialMediaLinks.forEach((key, value) {
      if (_controllers.containsKey(key) && value != "") {
        _controllers[key]!.text = value;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final profileProvider = context.read<ProfileProvider>();

    if (profileProvider.userSocialMedias.isNotEmpty) {
      _updateControllers(profileProvider.userSocialMedias);
    }

    // context.read<ProfileBloc>().add(
    //     GetUserEvent(userID: context.read<ProfileBloc>().cachedUserData!.id));
  }

  // @override
  // void dispose() {
  //   _instagramController.dispose();
  //   _linkedInController.dispose();
  //   _youtubeController.dispose();
  //   _telegramController.dispose();
  //   _tiktokController.dispose();
  //   _facebookController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return KeyboardAvoider(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Hero(
            tag: _hero,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin!, end: end!);
            },
            child: Material(
              color: appColors.background,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Consumer<ProfileProvider>(
                    builder: (context, value, child) {
                      return Column(
                        children: [
                          Text(
                            context.tr("add_medias_widget.title"),
                            style: TextStyle(
                              fontSize: 16,
                              color: appColors.secondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          _buildInstagramField(appColors),
                          const SizedBox(height: 12),
                          _buildFacebookField(appColors),
                          const SizedBox(height: 12),
                          _buildLinkedInField(appColors),
                          const SizedBox(height: 12),
                          _buildTelegramField(appColors),
                          const SizedBox(height: 12),
                          _buildTikTokField(appColors),
                          const SizedBox(height: 12),
                          _buildYouTubeField(appColors),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              final Map<String, dynamic> socialMediaLinks = {
                                "instagram":
                                    _controllers["instagram"]?.text ?? "",
                                "linkedIn":
                                    _controllers["linkedIn"]?.text ?? "",
                                "youtube": _controllers["youtube"]?.text ?? "",
                                "telegram":
                                    _controllers["telegram"]?.text ?? "",
                                "tiktok": _controllers["tiktok"]?.text ?? "",
                                "facebook":
                                    _controllers["facebook"]?.text ?? "",
                              };

                              context
                                  .read<ProfileProvider>()
                                  .updateSocialMedias(socialMediaLinks);

                              Future.microtask(() {
                                if (mounted) Navigator.pop(context);
                              });

                              // context.read<ProfileBloc>().add(
                              //       UpdateUserEvent(
                              //         socialMediaLinks: socialMediaLinks,
                              //       ),
                              //     );

                              // context.read<ProfileBloc>().add(GetUserEvent(
                              //     userID: context
                              //         .read<ProfileBloc>()
                              //         .cachedUserData!
                              //         .id));
                            },
                            child: Text(
                              context.tr("core.save"),
                              style: TextStyle(
                                fontSize: 18,
                                color: appColors.primary,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  // BlocConsumer<ProfileBloc, ProfileState>(
                  //   listener: (context, state) {
                  //     if (state is GotUserState) {
                  //       if (state.user.socialMediaLinks != null &&
                  //           state.user.socialMediaLinks!.isNotEmpty) {
                  //         _updateControllers(state.user.socialMediaLinks!);
                  //       }
                  //     }
                  //     if (state is UpdatedUserState && mounted) {
                  //       Future.microtask(() {
                  //         if (mounted) Navigator.pop(context);
                  //       });
                  //     }
                  //   },
                  //   builder: (context, state) {
                  //     if (state is GotUserState) {
                  //       return Column(
                  //         children: [
                  //           const Text(
                  //             "Add links to your social networks for easy communication with other users.",
                  //             style: TextStyle(
                  //               fontSize: 16,
                  //               color: appColors.secondary,
                  //             ),
                  //             textAlign: TextAlign.center,
                  //           ),
                  //           const SizedBox(height: 12),
                  //           _buildInstagramField(),
                  //           const SizedBox(height: 12),
                  //           _buildFacebookField(),
                  //           const SizedBox(height: 12),
                  //           _buildLinkedInField(),
                  //           const SizedBox(height: 12),
                  //           _buildTelegramField(),
                  //           const SizedBox(height: 12),
                  //           _buildTikTokField(),
                  //           const SizedBox(height: 12),
                  //           _buildYouTubeField(),
                  //           const SizedBox(height: 12),
                  //           TextButton(
                  //             onPressed: () {
                  //               final Map<String, dynamic> socialMediaLinks = {
                  //                 "instagram":
                  //                     _controllers["instagram"]?.text ?? "",
                  //                 "linkedIn":
                  //                     _controllers["linkedIn"]?.text ?? "",
                  //                 "youtube":
                  //                     _controllers["youtube"]?.text ?? "",
                  //                 "telegram":
                  //                     _controllers["telegram"]?.text ?? "",
                  //                 "tiktok": _controllers["tiktok"]?.text ?? "",
                  //                 "facebook":
                  //                     _controllers["facebook"]?.text ?? "",
                  //               };

                  //               context.read<ProfileBloc>().add(
                  //                     UpdateUserEvent(
                  //                       socialMediaLinks: socialMediaLinks,
                  //                     ),
                  //                   );

                  //               context.read<ProfileBloc>().add(GetUserEvent(
                  //                   userID: context
                  //                       .read<ProfileBloc>()
                  //                       .cachedUserData!
                  //                       .id));
                  //             },
                  //             child: const Text(
                  //               "Save",
                  //               style: TextStyle(
                  //                 fontSize: 18,
                  //                 color: AppTheme.primaryColor,
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       );
                  //     } else {
                  //       return const Center(
                  //         child: CircularProgressIndicator(
                  //           color: AppTheme.primaryColor,
                  //         ),
                  //       );
                  //     }
                  //   },
                  // ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstagramField(AppColors appColors) {
    return Row(
      children: [
        Icon(
          MingCuteIcons.mgc_instagram_line,
          color: appColors.secondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _controllers["instagram"],
            onChanged: (value) {
              setState(() {});
            },
            maxLines: 1,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey[800]!,
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey[500]!,
                  width: 2.0,
                ),
              ),
              fillColor: appColors.background,
              filled: true,
              hintText: context.tr("add_medias_widget.instagram"),
              // "Where can we find you on Instagram?",
              // "Share your Instagram! 📸"
              // "Let’s connect on Instagram! 🌟"
              hintStyle: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            style: TextStyle(color: appColors.secondary),
          ),
        ),
        const SizedBox(width: 8),
        if (_controllers["instagram"]!.text != "")
          IconButton(
            onPressed: () {
              setState(() {
                _controllers["instagram"]!.clear();
              });
            },
            icon: Icon(
              MingCuteIcons.mgc_delete_2_line,
              color: Colors.red[600],
            ),
          ),
      ],
    );
  }

  Widget _buildFacebookField(AppColors appColors) {
    return Row(
      children: [
        Icon(
          MingCuteIcons.mgc_facebook_fill,
          color: appColors.secondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _controllers["facebook"],
            onChanged: (value) {
              setState(() {});
            },
            maxLines: 1,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey[800]!,
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey[500]!,
                  width: 2.0,
                ),
              ),
              fillColor: appColors.background,
              filled: true,
              hintText: context.tr("add_medias_widget.facebook"),
              hintStyle: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            style: TextStyle(color: appColors.secondary),
          ),
        ),
        const SizedBox(width: 8),
        if (_controllers["facebook"]!.text != "")
          IconButton(
            onPressed: () {
              setState(() {
                _controllers["facebook"]!.clear();
              });
            },
            icon: Icon(
              MingCuteIcons.mgc_delete_2_line,
              color: Colors.red[600],
            ),
          ),
      ],
    );
  }

  Widget _buildLinkedInField(AppColors appColors) {
    return Row(
      children: [
        Icon(
          MingCuteIcons.mgc_linkedin_fill,
          color: appColors.secondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _controllers["linkedIn"],
            onChanged: (value) {
              setState(() {});
            },
            maxLines: 1,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey[800]!,
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey[500]!,
                  width: 2.0,
                ),
              ),
              fillColor: appColors.background,
              filled: true,
              hintText: context.tr("add_medias_widget.linkedin"),
              hintStyle: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            style: TextStyle(color: appColors.secondary),
          ),
        ),
        const SizedBox(width: 8),
        if (_controllers["linkedIn"]!.text != "")
          IconButton(
            onPressed: () {
              setState(() {
                _controllers["linkedIn"]!.clear();
              });
            },
            icon: Icon(
              MingCuteIcons.mgc_delete_2_line,
              color: Colors.red[600],
            ),
          ),
      ],
    );
  }

  Widget _buildTelegramField(AppColors appColors) {
    return Row(
      children: [
        Icon(
          MingCuteIcons.mgc_telegram_fill,
          color: appColors.secondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _controllers["telegram"],
            onChanged: (value) {
              setState(() {});
            },
            maxLines: 1,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey[800]!,
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey[500]!,
                  width: 2.0,
                ),
              ),
              fillColor: appColors.background,
              filled: true,
              hintText: context.tr("add_medias_widget.tg"),
              hintStyle: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            style: TextStyle(color: appColors.secondary),
          ),
        ),
        const SizedBox(width: 8),
        if (_controllers["telegram"]!.text != "")
          IconButton(
            onPressed: () {
              setState(() {
                _controllers["telegram"]!.clear();
              });
            },
            icon: Icon(
              MingCuteIcons.mgc_delete_2_line,
              color: Colors.red[600],
            ),
          ),
      ],
    );
  }

  Widget _buildTikTokField(AppColors appColors) {
    return Row(
      children: [
        Icon(
          MingCuteIcons.mgc_tiktok_fill,
          color: appColors.secondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _controllers["tiktok"],
            onChanged: (value) {
              setState(() {});
            },
            maxLines: 1,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey[800]!,
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey[500]!,
                  width: 2.0,
                ),
              ),
              fillColor: appColors.background,
              filled: true,
              hintText: context.tr("add_medias_widget.tiktok"),
              hintStyle: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            style: TextStyle(color: appColors.secondary),
          ),
        ),
        const SizedBox(width: 8),
        if (_controllers["tiktok"]!.text != "")
          IconButton(
            onPressed: () {
              setState(() {
                _controllers["tiktok"]!.clear();
              });
            },
            icon: Icon(
              MingCuteIcons.mgc_delete_2_line,
              color: Colors.red[600],
            ),
          ),
      ],
    );
  }

  Widget _buildYouTubeField(AppColors appColors) {
    return Row(
      children: [
        Icon(
          MingCuteIcons.mgc_youtube_fill,
          color: appColors.secondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _controllers["youtube"],
            onChanged: (value) {
              setState(() {});
            },
            maxLines: 1,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey[800]!,
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey[500]!,
                  width: 2.0,
                ),
              ),
              fillColor: appColors.background,
              filled: true,
              hintText: context.tr("add_medias_widget.yt"),
              hintStyle: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            style: TextStyle(color: appColors.secondary),
          ),
        ),
        const SizedBox(width: 8),
        if (_controllers["youtube"]!.text != "")
          IconButton(
            onPressed: () {
              setState(() {
                _controllers["youtube"]!.clear();
              });
            },
            icon: Icon(
              MingCuteIcons.mgc_delete_2_line,
              color: Colors.red[600],
            ),
          ),
      ],
    );
  }
}
