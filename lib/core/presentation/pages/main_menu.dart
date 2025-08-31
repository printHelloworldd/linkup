import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/config/theme/theme_getter.dart';
import 'package:linkup/core/data/datasources/remote/database_datasource.dart';
import 'package:linkup/core/data/repository/database_repository_impl.dart';
import 'package:linkup/core/domain/usecases/check_user_data_uc.dart';
import 'package:linkup/core/domain/usecases/init_notifications_uc.dart';
import 'package:linkup/core/domain/usecases/real%20time%20database/update_user_status_uc.dart';
import 'package:linkup/core/presentation/pages/mobile_scanner_page.dart';
import 'package:linkup/core/presentation/widgets/empty_data_dialog.dart';
import 'package:linkup/core/presentation/widgets/update_dialog.dart';
import 'package:linkup/features/Authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:linkup/features/Authentication/presentation/pages/create%20profile%20pages/main_page.dart';
import 'package:linkup/features/Chat/presentation/pages/chats_list_page.dart';
import 'package:linkup/features/Profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:linkup/features/Profile/presentation/bloc/app_version/app_version_bloc.dart';
import 'package:linkup/features/Profile/presentation/pages/profile_page.dart';
import 'package:linkup/features/Recommendation%20System/presentation/pages/recommendation_page.dart';
import 'package:linkup/features/Search%20User/presentation/pages/search_user_page.dart';
import '/injection_container.dart' as di;

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final sl = GetIt.instance;

  final InitNotificationsUc initNotificationsUc = di.sl<InitNotificationsUc>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final String currentUserID;
  late bool isUserVerified;
  bool isUserCreated = true;

  int selectedIndex = 0;

  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    _checkUser();

    currentUserID = _auth.currentUser!.uid;
    context.read<ProfileBloc>().add(GetUserEvent(userID: currentUserID));

    //* Has user generated seed phrase, if he has the user is considered as verified
    isUserVerified = context
            .read<ProfileBloc>()
            .cachedUserData
            ?.privateDataEntity
            ?.isVerified ??
        false;

    pages = [
      const ChatsListPage(),
      const SearchUserPage(),
      const RecommendationPage(),
      const ProfilePage(),
    ];

    setOnlineStatus();

    context.read<AuthBloc>().add(InitNotifications(userID: currentUserID));

    // Проверяем обновления при запуске
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String? senderUserID;

      context.read<AppVersionBloc>().add(CheckForUpdates());

      checkNotificationPermission(context, currentUserID);

      final Future<RemoteMessage?> remoteMessage =
          FirebaseMessaging.instance.getInitialMessage();

      remoteMessage.then((msg) {
        if (msg != null) {
          senderUserID = msg.data["senderID"];
        }
      });
    });

    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      print('🔹 Обработка в фоне: ${message.data}');
    });
  }

  void _firebaseMessagingBackgroundHandler(RemoteMessage remoteMessage) {
    final String senderUserID = remoteMessage.data["senderID"];
  }

  Future<void> _checkUser() async {
    final isCreated = await sl<CheckUserDataUc>().call();
    if (!mounted) return;

    setState(() {
      isUserCreated = isCreated;
    });
  }

  Future<void> checkNotificationPermission(
      BuildContext context, String userID) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      // ❌ Уведомления запрещены – показываем кастомное сообщение
      showDeniedNotificationsDialog(context);
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      // ❌ Уведомления запрещены – показываем кастомное сообщение
      showRequestNotificationsDialog(context, userID);
    }
  }

  void showRequestNotificationsDialog(BuildContext context, String userID) {
    showAdaptiveDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        final AppColors appColors = dialogContext.theme.appColors;

        return AlertDialog(
          backgroundColor: appColors.secondary,
          title: Row(
            children: [
              Icon(
                MingCuteIcons.mgc_notification_fill,
                color: appColors.background,
              ),
              const SizedBox(width: 8),
              Text(
                dialogContext.tr("main_menu.allow"),
                style: TextStyle(color: appColors.background),
              ),
            ],
          ),
          content: Text(
            dialogContext.tr("main_menu.notify"),
            style: TextStyle(color: appColors.background),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                dialogContext.tr("core.cancel"),
                style: TextStyle(
                  color: Colors.grey[800],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                dialogContext
                    .read<AuthBloc>()
                    .add(InitNotifications(userID: currentUserID));
              },
              child: Text(
                dialogContext.tr("core.allow"),
                style: TextStyle(
                  color: appColors.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showDeniedNotificationsDialog(BuildContext context) {
    showAdaptiveDialog(
      barrierDismissible: true,
      context: context,
      builder: (dialogContext) {
        final AppColors appColors = dialogContext.theme.appColors;

        return AlertDialog(
          backgroundColor: appColors.secondary,
          title: Row(
            children: [
              Icon(
                MingCuteIcons.mgc_notification_off_fill,
                color: appColors.background,
              ),
              const SizedBox(width: 8),
              Text(
                dialogContext.tr("main_menu.disabled"),
                style: TextStyle(color: appColors.background),
              ),
            ],
          ),
          content: Text(
            dialogContext.tr("main_menu.disabled_info"),
            style: TextStyle(color: appColors.background),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "Ok",
                style: TextStyle(
                  color: appColors.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void setOnlineStatus() {
    UpdateUserStatusUc(DatabaseRepositoryImpl(DatabaseDatasource())).call(true);
  }

  void _showAlertDialog(AppColors appColors, BuildContext context) {
    showAdaptiveDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: appColors.secondary,
          title: Text(
            context.tr("main_menu.key_transfer"),
            style: TextStyle(color: appColors.background),
          ),
          content: Text(
            context.tr("main_menu.transfer_info"),
            style: TextStyle(color: appColors.background),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.tr("core.cancel"),
                style: TextStyle(
                  color: Colors.grey[800],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MobileScannerPage(),
                  ),
                );
                // await Permission.camera.request();
              },
              child: Text(
                context.tr("main_menu.scan"),
                style: TextStyle(
                  color: appColors.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    if (!isUserCreated) {
      return const MainPage(isUserRegistered: true);
    }

    return Scaffold(
      body: SafeArea(child: pages[selectedIndex]),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: MultiBlocListener(
          listeners: [
            BlocListener<ProfileBloc, ProfileState>(
              listener: (context, state) async {
                if (state is GotUserState) {
                  if (state.user == null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const MainPage(isUserRegistered: true),
                      ),
                    );
                  }
                  if (state.isCryptoDataEmpty) {
                    EmptyDataDialog.showAlertDialog(context,
                        state.user!.privateDataEntity?.isVerified ?? false);
                  }
                }
              },
            ),
            BlocListener<AppVersionBloc, AppVersionState>(
              listener: (context, state) {
                if (state is UpdateIsAvailable) {
                  UpdateDialog.showUpdateDialog(context, state.newVersion);
                }
              },
            ),
          ],
          child: GNav(
            backgroundColor: appColors.background,
            color: appColors.secondary,
            activeColor: appColors.primary,
            tabBackgroundColor: appColors.surface,
            padding: const EdgeInsets.all(16),
            gap: 8.0,
            onTabChange: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            tabs: [
              // TODO: Edit package to have ability to set custom icon from iconify_flutter package
              GButton(
                icon: Icons.chat,
                text: context.tr("nav_bar.chats"),
                leading: const Icon(MingCuteIcons.mgc_chat_1_line, size: 24),
              ),
              GButton(
                icon: Icons.explore_rounded,
                text: context.tr("nav_bar.explore"),
              ),
              GButton(
                // iconifyIcon:
                //     Iconify(MaterialSymbols.personalized_recommendations),
                icon: Icons.people_alt_rounded, // .explore
                text: "Recs", // TODO: Localize
                leading: const Icon(MingCuteIcons.mgc_group_3_fill, size: 24),
              ),
              GButton(
                icon: Icons.person_outline,
                text: context.tr("nav_bar.profile"),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Точка
                    BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, state) {
                        if (state is GotUserState) {
                          if (!state.user!.privateDataEntity!.isVerified) {
                            return Container(
                              height: 6,
                              width: 6,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: appColors.primary,
                              ),
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      },
                    ),

                    // Иконка
                    const Icon(MingCuteIcons.mgc_user_2_fill, size: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
