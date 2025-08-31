import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:lottie/lottie.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/presentation/bloc/user%20blocking/user_blocking_bloc.dart';
import 'package:linkup/features/Profile/presentation/pages/user_profile_page.dart';
import 'package:linkup/features/Profile/presentation/bloc/profile/profile_bloc.dart';

class BlockedUsersPage extends StatefulWidget {
  final String currentUserID;

  const BlockedUsersPage({super.key, required this.currentUserID});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  @override
  void initState() {
    super.initState();
    context.read<UserBlockingBloc>().add(
          GetBlockedUsersEvent(currentUserID: widget.currentUserID),
        );
  }

  void _showUserUnblockingDialog(
    AppColors appColors, {
    required BuildContext context,
    required UserEntity receiverUser,
    required String currentUserID,
  }) {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              // backgroundColor: AppTheme.backgroundColor,
              title: Text(
                context.tr(
                  "blocked_users_page.unblock_user",
                  namedArgs: {"fullName": receiverUser.fullName},
                ),
              ),
              content: RichText(
                text: TextSpan(
                  text: context.tr("blocked_users_page.alert_content"),
                  // style: const TextStyle(color: AppTheme.secondaryColor),
                  children: [
                    TextSpan(
                      text: receiverUser.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        // color: AppTheme.secondaryColor,
                      ),
                    ),
                    TextSpan(
                      text: context.tr("blocked_users_page.on"),
                      // style: const TextStyle(
                      //   color: AppTheme.secondaryColor,
                      // ),
                    ),
                  ],
                ),
              ),
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
                    context.read<UserBlockingBloc>().add(
                          UnblockUserEvent(
                            currentUserID: currentUserID,
                            blockedUserID: receiverUser.id,
                          ),
                        );

                    context
                        .read<ProfileBloc>()
                        .add(UpdateUserEvent(blockedUser: receiverUser.id));

                    Navigator.pop(context);
                  },
                  child: Text(
                    context.tr("blocked_users_page.unblock_user"),
                    style: TextStyle(
                      color: appColors.primary,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: _buildBlockedUsersList(appColors),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        context.tr("blocked_users_page.title"),
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
    );
  }

  Widget _buildBlockedUsersList(AppColors appColors) {
    return BlocBuilder<UserBlockingBloc, UserBlockingState>(
      builder: (context, state) {
        if (state is LoadingBlockedUsers) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is LoadedBlockedUsers) {
          if (state.blockedUsers.isEmpty) {
            return Center(
              child: Lottie.asset("assets/animations/Animation - Nothing.json"),
              // child: Text("Nothing here"),
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.blockedUsers.length,
                    itemBuilder: (context, index) {
                      final profileImage =
                          state.blockedUsers[index].profileImageUrl;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserProfilePage(
                                  user: state.blockedUsers[index],
                                  navigatedFromChatPage: false,
                                ),
                              ),
                            );
                          },
                          leading: profileImage == null
                              ? Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: appColors.secondary,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: const ClipOval(
                                    child: Icon(
                                      Icons.person_outline_rounded,
                                      size: 36,
                                    ),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 24,
                                  backgroundImage: CachedNetworkImageProvider(
                                    profileImage,
                                  ),
                                ),
                          title: Text(
                            state.blockedUsers[index].fullName,
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              _showUserUnblockingDialog(
                                appColors,
                                context: context,
                                receiverUser: state.blockedUsers[index],
                                currentUserID: widget.currentUserID,
                              );
                            },
                            child: Text(
                              context.tr("blocked_users_page.unblock"),
                              style: TextStyle(
                                color: appColors.primary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        } else {
          return Center(
            child: Text(context.tr("core.smth_went_wrong")),
          );
        }
      },
    );
  }
}
