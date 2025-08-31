import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/core/data/datasources/remote/database_datasource.dart';
import 'package:linkup/core/data/repository/database_repository_impl.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/usecases/real%20time%20database/update_user_status_uc.dart';
import 'package:linkup/core/presentation/pages/check_pin_page.dart';
import 'package:linkup/core/presentation/pages/privacy_policy_page.dart';
import 'package:linkup/core/presentation/widgets/empty_data_dialog.dart';
import 'package:linkup/core/presentation/widgets/update_dialog.dart';
import 'package:linkup/features/Authentication/presentation/pages/create%20profile%20pages/main_page.dart';
import 'package:linkup/features/Profile/presentation/bloc/app_version/app_version_bloc.dart';
import 'package:linkup/features/Profile/presentation/pages/blocked_users_page.dart';
import 'package:linkup/features/Profile/presentation/pages/edit_profile_page.dart';
import 'package:linkup/features/Profile/presentation/pages/mnemonic_page.dart';
import 'package:linkup/features/Profile/presentation/widgets/qr_code_widget.dart';

class SettingsPage extends StatefulWidget {
  final UserEntity userData;

  const SettingsPage({
    super.key,
    required this.userData,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final UserEntity userData;
  late bool isUserVerified;
  late bool isPrivateDataEmpty;

  late final String appVersion;

  Future<void> setOfflineStatus() async {
    await UpdateUserStatusUc(DatabaseRepositoryImpl(DatabaseDatasource()))
        .call(false);
  }

  @override
  void initState() {
    super.initState();
    userData = widget.userData;

    appVersion = context.read<AppVersionBloc>().appVersion ?? "Unknown";

    //* Has user generated seed phrase, if he has the user is considered as verified
    isUserVerified = userData.privateDataEntity?.isVerified ?? false;
    isPrivateDataEmpty =
        UserEntity.isPrivateDataEmpty(userData.privateDataEntity);
  }

  void showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(context.tr("settings_page.no_updates")),
        actionsAlignment: MainAxisAlignment.center,
        content: Text(context.tr("settings_page.already")),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Ok',
              style: TextStyle(
                  // color: AppTheme.primaryColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // TODO: Localize
  // void showUpdateFailureDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       title: Text(context.tr("settings_page.no_updates")),
  //       actionsAlignment: MainAxisAlignment.center,
  //       content: Text(context.tr("settings_page.already")),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //           },
  //           child: const Text(
  //             'Ok',
  //             style: TextStyle(
  //               color: AppTheme.primaryColor,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showEmptyDataAlert(BuildContext context) {
    EmptyDataDialog.showAlertDialog(context, isUserVerified);
  }

  @override
  Widget build(BuildContext context) {
    // final arguments =
    //     ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // final UserEntity? userData = arguments?["user"];

    final ThemeData theme = context.theme;
    final AppColors appColors = theme.appColors;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.tr("settings_page.title"),
                    style: TextStyle(
                      color: appColors.secondary,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // EditProfileWidget(userData: userData),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(
                            userData: userData,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      decoration: BoxDecoration(
                        color: appColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined),
                          const SizedBox(width: 10),
                          Text(
                            context.tr("settings_page.edit_profile"),
                            style: TextStyle(
                              color: appColors.secondary,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // GestureDetector(
                  //   onTap: () {},
                  //   child: Container(
                  //     width: MediaQuery.of(context).size.width,
                  //     padding: const EdgeInsets.symmetric(
                  //         horizontal: 10, vertical: 15),
                  //     decoration: BoxDecoration(
                  //       color: Colors.grey[850],
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     child: const Row(
                  //       children: [
                  //         Icon(Icons.notifications_none_rounded),
                  //         SizedBox(width: 10),
                  //         Text(
                  //           "Notifications",
                  //           style: TextStyle(
                  //             color: AppTheme.secondaryColor,
                  //             fontSize: 18,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 12),
                  // Container(
                  //   width: MediaQuery.of(context).size.width,
                  //   padding: const EdgeInsets.symmetric(
                  //       horizontal: 10, vertical: 15),
                  //   decoration: BoxDecoration(
                  //     color: Colors.grey[850],
                  //     borderRadius: BorderRadius.circular(8),
                  //   ),
                  //   child: const Row(
                  //     children: [
                  //       Icon(Icons.person_outline_rounded),
                  //       SizedBox(width: 10),
                  //       Text(
                  //         "Account settings",
                  //         style: TextStyle(
                  //           color: AppTheme.secondaryColor,
                  //           fontSize: 18,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return BlockedUsersPage(currentUserID: userData.id);
                      }));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      decoration: BoxDecoration(
                        color: appColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.block_rounded),
                          const SizedBox(width: 10),
                          Text(
                            context.tr("settings_page.blocked_users"),
                            style: TextStyle(
                              color: appColors.secondary,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  BlocConsumer<AppVersionBloc, AppVersionState>(
                    listener: (context, state) {
                      if (state is UpdatesIsNotAvailable) {
                        showInfoDialog(context);
                      } else if (state is UpdateIsAvailable) {
                        UpdateDialog.showUpdateDialog(
                            context, state.newVersion);
                      } /* else if (state is UpdateCheckingFailure) {
                        showUpdateFailureDialog(context);
                      } */
                    },
                    builder: (context, state) => GestureDetector(
                      onTap: () async {
                        context.read<AppVersionBloc>().add(CheckForUpdates());
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        decoration: BoxDecoration(
                          color: appColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(MingCuteIcons.mgc_refresh_1_line),
                                const SizedBox(width: 10),
                                Text(
                                  context.tr("settings_page.check"),
                                  style: TextStyle(
                                    color: appColors.secondary,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            Text("v$appVersion"),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const QrCodeWidget(),

                  const SizedBox(height: 12),

                  if (!isUserVerified)
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (!isPrivateDataEmpty) {
                              final bool result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CheckPinPage(),
                                ),
                              );

                              if (result) {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const MnemonicPage();
                                }));
                              }
                            } else {
                              _showEmptyDataAlert(context);
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            decoration: BoxDecoration(
                              color: appColors.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(MingCuteIcons.mgc_keyhole_line),
                                const SizedBox(width: 10),
                                Text(
                                  "Generate seed phrase",
                                  style: TextStyle(
                                    color: appColors.secondary,
                                    fontSize: 18,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  height: 6,
                                  width: 6,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: appColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                  GestureDetector(
                    onTap: () async {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const PrivacyPolicyPage();
                      }));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      decoration: BoxDecoration(
                        color: appColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(MingCuteIcons.mgc_shield_shape_line),
                          const SizedBox(width: 10),
                          Text(
                            "Privacy Policy",
                            style: TextStyle(
                              color: appColors.secondary,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            TextButton(
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.transparent),
              ),
              onPressed: () async {
                // _clearState(context);
                // Navigator.popUntil(context, (route) => route.isFirst);
                // Navigator.pushReplacementNamed(
                //     context, "/main_registration_page");
                // Navigator.pop(context);

                // Navigator.of(context).pushAndRemoveUntil(
                //   MaterialPageRoute(builder: (context) => const MainApp()),
                //   (route) => false, // Удаляет все предыдущие экраны
                // );
                await setOfflineStatus();
                FirebaseAuth.instance.signOut();

                // await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) =>
                            const MainPage(isUserRegistered: false)),
                  );
                }

                // setState(() {});
                // context.read<AuthBloc>().add(SignOutEvent());
                // await context.read<AuthenticationProvider>().signOut();
              },
              child: Text(
                context.tr("settings_page.log_out"),
                style: TextStyle(
                  color: Colors.red[600]!,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
