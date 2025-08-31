/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:linkup/features/Crypto/data/datasource/mobile_crypto_datasource.dart';
import 'package:provider/provider.dart';
import 'package:linkup/app_providers.dart';
import 'package:linkup/config/theme/cubit/theme_cubit.dart';
import 'package:linkup/features/Chat/presentation/provider/chat_provider.dart';
import 'package:linkup/features/Chat/presentation/provider/chats_list_provider.dart';
import 'package:linkup/features/Profile/presentation/provider/profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upgrader/upgrader.dart';
import 'package:wiredash/wiredash.dart';

import 'package:linkup/features/Authentication/presentation/pages/create%20profile%20pages/main_page.dart';
import 'package:linkup/features/Authentication/presentation/pages/verification_page.dart';
import 'package:linkup/firebase_options.dart';

import 'injection_container.dart' as di;

/// Entry point of the application.
///
/// Initializes:
/// - Flutter bindings
/// - EasyLocalization (for multi-language support)
/// - Firebase with web options
/// - Firebase AppCheck with ReCaptcha v3
/// - Dependency injection (via `di.init()`)
/// - Supabase client with `SUPABASE_PROJECT_URL` and `SUPABASE_ANON_KEY`
/// - Web app version checking
///
/// Wraps the app with:
/// - EasyLocalization
/// - MultiBlocProvider
/// - MultiProvider
/// - Wiredash feedback system
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox<String>('encryptedBox');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  // await FirebaseAppCheck.instance.activate(
  //   webProvider:
  //       ReCaptchaV3Provider("6Ld6_xUrAAAAAOu7sbl7HQsTJhuU712ECEzEQ8Af"),
  // );

  await di.init();

  const supabaseUrl = String.fromEnvironment('SUPABASE_PROJECT_URL');
  const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  final cryptoData = await MobileCryptoDatasource()
      .generateCryptographyData(userID: "id", pin: "1234");
  print(cryptoData);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale("en"), Locale("uk"), Locale("ru")],
      path: 'assets/localization',
      fallbackLocale: const Locale("en"),
      useOnlyLangCode: true,
      child: const MainApp(),
    ),
  );
}

/// The root widget of the application.
///
/// Sets up:
/// - `MultiBlocProvider`: all BLoCs used across the app
/// - `MultiProvider`: any ChangeNotifiers used
/// - `Wiredash`: feedback tool with hidden screenshot option
/// - `GetMaterialApp`: app with localization, theming, routing
///
/// The home screen is conditionally rendered based on Firebase auth state:
/// - If authenticated: goes to `VerificationPage`
/// - If not: goes to `MainPage(isUserRegistered: false)`
class MainApp extends StatelessWidget {
  // final FirebaseAuth? auth;

  const MainApp({
    super.key,
    // this.auth,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: getAppBlocProviders(),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ChatProvider()),
          ChangeNotifierProvider(create: (context) => ProfileProvider()),
          ChangeNotifierProvider(create: (context) => ChatsListProvider()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeData>(
          builder: (context, theme) {
            return Wiredash(
              feedbackOptions: const WiredashFeedbackOptions(
                screenshot: ScreenshotPrompt.optional,
              ),
              projectId: "linkup-xfvlvef",
              secret: const String.fromEnvironment('WIREDASH_SECRET'),
              child: GetMaterialApp(
                debugShowCheckedModeBanner: false,
                title: "LinkUp",
                // home: MainPage(),
                theme: theme,
                // darkTheme: AppTheme2.lightTheme,
                // themeMode: ThemeMode.dark,

                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,

                home: UpgradeAlert(
                  upgrader: Upgrader(
                    debugLogging: true,
                    // showIgnore: false,
                    // showLater: false,
                    // canDismissDialog: false,
                    debugDisplayAlways: true, // Always show upgrade dialog
                    minAppVersion:
                        '1.0.0-beta.1', // Simulate "required" upgrade if lower
                  ),
                  child: StreamBuilder(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasData) {
                        if (kDebugMode) {
                          print(
                              "User logged in as ${FirebaseAuth.instance.currentUser!.email}");
                        }
                        return const VerificationPage();
                      } else {
                        if (kDebugMode) {
                          print("User isn't logged in");
                        }
                        return const MainPage(isUserRegistered: false);
                      }
                    },
                  ),
                ),
              ).animate().fadeIn(),
            );
          },
        ),
      ),
    );
  }
}
