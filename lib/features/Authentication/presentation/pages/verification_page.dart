import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:lottie/lottie.dart';
import 'package:linkup/config/dimensions.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/core/presentation/pages/main_menu.dart';
import 'package:linkup/features/Authentication/presentation/pages/create%20profile%20pages/main_page.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool isEmailVerified = false;
  Timer? timer;
  String email = "";

  @override
  void initState() {
    super.initState();
    // user needs to be created before
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    email = FirebaseAuth.instance.currentUser!.email ?? "";

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  void sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
    } catch (e) {
      if (kDebugMode) {
        print("Failed to send verification email: $e");
      }
    }
  }

  void checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Пользователь вышел из системы — отменяем таймер
      timer?.cancel();
      return;
    }

    await user.reload();

    setState(() {
      isEmailVerified = user.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isEmailVerified) {
      return const MainMenu();
    } else {
      final ThemeData theme = context.theme;
      final AppColors appColors = theme.appColors;

      final currentWidth = MediaQuery.of(context).size.width;

      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 36),
                    Text(
                      context.tr("verification_page.check"),
                      style: theme.welcomeTextTheme.textStyle,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      textAlign: TextAlign.center,
                      context.tr(
                        "verification_page.click",
                        namedArgs: {"email": email},
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(
                      thickness: 1.0,
                      height: 1.0,
                      color: appColors.secondary,
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(context.tr("verification_page.not_sent")),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            sendVerificationEmail();
                          },
                          child: Text(
                            context.tr("verification_page.try_again"),
                            style: TextStyle(
                              color: appColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        timer?.cancel(); // остановить проверку
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) =>
                                    const MainPage(isUserRegistered: false)),
                          );
                        }
                      },
                      child: Text(
                        context.tr("core.cancel"),
                        style: TextStyle(
                          color: appColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                currentWidth < mobileWidth
                    ? Lottie.asset(
                        "assets/animations/Animation - Email.json",
                        repeat: true,
                      )
                    : SizedBox(
                        height: 200,
                        width: 200,
                        child: Lottie.asset(
                          "assets/animations/Animation - Email.json",
                          repeat: true,
                        ),
                      ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
