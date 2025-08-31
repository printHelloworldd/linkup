import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_snack_bar_theme.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/core/presentation/navigation_service.dart';
import 'package:linkup/core/presentation/pages/privacy_policy_page.dart';
import 'package:linkup/core/presentation/pages/tos_page.dart';
import 'package:linkup/features/Authentication/presentation/pages/pin_page.dart';
import 'package:linkup/features/Authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:linkup/features/Authentication/presentation/pages/login_page.dart';
import 'package:linkup/features/Authentication/presentation/widgets/app_icon.dart';
import 'package:linkup/features/Authentication/presentation/widgets/custom_button.dart';
import 'package:linkup/features/Authentication/presentation/widgets/auth_textfield.dart';
import 'package:linkup/features/Authentication/presentation/widgets/o_auth_panel.dart';
import 'package:linkup/features/Authentication/presentation/widgets/or_continue_with.dart';
import 'package:linkup/injection_container.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final PanelController panelController = PanelController();
  double panelOpacity = 0.0;

  String passwordStrength = "";
  Color passwordStrengthColor = Colors.grey[800]!;
  double _entropy = 0.0;

  void _showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      // backgroundColor: theme.colorScheme.,
      fontSize: 16,
      // textColor: AppTheme.backgroundColor,
    );
  }

  void _showWebToast(BuildContext context, String msg) {
    final AppSnackBarTheme appSnackBarTheme = context.theme.appSnackBarTheme;

    String text = "";
    if (msg == "Exception: invalid-email") {
      text = context.tr("auth_page.invalid_email");
    } else if (msg == "Exception: weak-password") {
      text = context.tr("auth_page.psw_too_weak");
    } else {
      text = msg;
    }

    FToast().init(context).showToast(
          child: Container(
            padding: appSnackBarTheme.padding,
            decoration: appSnackBarTheme.error.decoration,
            child: Text(
              text,
              style: appSnackBarTheme.error.textStyle,
            ),
          ),
        );
  }

  void calculatePasswordEntropy(String password) {
    int length = password.length;
    int R = getAlphabetSize(password);

    // if (R == 0 || length == 0) return 0; // Если пароль пустой

    double entropy = log(R) / log(2) * length;

    setState(() {
      _entropy = entropy;
      switch (entropy) {
        case < 30:
          passwordStrength = context.tr("auth_page.too_weak");
          passwordStrengthColor = Colors.red[600]!;
          break;
        case < 50:
          passwordStrength = context.tr("auth_page.normal");
          passwordStrengthColor = Colors.yellow;
          break;
        case < 70:
          passwordStrength = context.tr("auth_page.good");
          passwordStrengthColor = Colors.yellow;
          break;
        case > 70:
          passwordStrength = context.tr("auth_page.great");
          passwordStrengthColor = Colors.green[700]!;
          break;
        default:
          passwordStrength = "";
          passwordStrengthColor = Colors.grey[800]!;
      }
    });
  }

  int getAlphabetSize(String password) {
    bool hasLower = false;
    bool hasUpper = false;
    bool hasDigits = false;
    bool hasSpecial = false;

    for (var char in password.runes) {
      if (char >= 48 && char <= 57) {
        hasDigits = true; // 0-9
      } else if (char >= 65 && char <= 90) {
        hasUpper = true;
      } // A-Z
      else if (char >= 97 && char <= 122) {
        hasLower = true;
      } // a-z
      else {
        hasSpecial = true;
      } // Спецсимволы
    }

    int R = 0;
    if (hasLower) R += 26; // a-z
    if (hasUpper) R += 26; // A-Z
    if (hasDigits) R += 10; // 0-9
    if (hasSpecial) R += 32; // Примерный диапазон спецсимволов

    return R;
  }

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthSignedIn || current is AuthSignedInViaGoogle,
      listener: (context, state) {
        if (state is AuthSignedIn) {
          // sl<NavigationService>()
          //     .pushReplacement(context, const VerificationPage());

          sl<NavigationService>().pushReplacement(context, const PinPage());
        }
        if (state is AuthSignedInViaGoogle) {
          // sl<NavigationService>().pushReplacement(context, const MainMenu());

          sl<NavigationService>().pushReplacement(context, const PinPage());
        }
        if (state is AuthSigningUpFailure) {
          if (!kIsWeb) {
            _showToast(state.exception.toString());
          } else {
            _showWebToast(context, state.exception.toString());
          }
        }
        if (state is AuthSigningInViaGoogleFailure) {
          if (!kIsWeb) {
            _showToast(state.exception.toString());
          } else {
            _showWebToast(context, state.exception.toString());
          }
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              double screenHeight = constraints.maxHeight;
              // double screenWidth = constraints.maxWidth;

              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.05),

                      const AppIcon(
                        iconPath: "assets/icons/link.png",
                        size: 96,
                      ),

                      SizedBox(height: screenHeight * 0.05),

                      _buildWelcomeText(context),

                      SizedBox(height: screenHeight * 0.03),

                      // Email textfield
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: AuthTextfield(
                          controller: _emailController,
                          obscureText: false,
                          hintText: context.tr("core.email"),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Password textfield
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: AuthTextfield(
                          controller: _passwordController,
                          obscureText: true,
                          hintText: context.tr("core.psw"),
                          onChanged: (psw) {
                            calculatePasswordEntropy(psw);
                          },
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),

                      _buildPasswordStrengthIndicator(
                          screenHeight: screenHeight),

                      SizedBox(height: screenHeight * 0.03),

                      // Sign up button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          if (state is AuthSigningIn) {
                            return CustomButton(
                              onTap: () {},
                              child: CircularProgressIndicator(
                                color: appColors.background,
                              ),
                            );
                          }
                          return CustomButton(
                            onTap: () {
                              context.read<AuthBloc>().add(SignUp(
                                  email: _emailController.text,
                                  password: _passwordController.text));
                            },
                            child: Text(
                              context.tr("auth_page.sign_up"),
                              style: TextStyle(
                                color: appColors.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Or continue with
                      const OrContinueWith(),

                      SizedBox(height: screenHeight * 0.02),

                      // Google, facebook, apple sign in buttons
                      const OAuthPanel(),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: "By signing up you agree to our ",
                            style: TextStyle(color: appColors.secondary),
                            children: [
                              TextSpan(
                                text: "Terms of Service ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: appColors.primary,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return const TosPage();
                                    }));
                                  },
                              ),
                              TextSpan(
                                text: "and ",
                                style: TextStyle(
                                  color: appColors.secondary,
                                ),
                              ),
                              TextSpan(
                                text: "Privacy Policy",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: appColors.primary,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return const PrivacyPolicyPage();
                                    }));
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return Column(
      children: [
        Text(
          context.tr("auth_page.reg_title"),
          style: context.theme.welcomeTextTheme.textStyle,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.tr("auth_page.reg_subtitle"),
              style: TextStyle(
                fontSize: 20,
                color: appColors.secondary,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                sl<NavigationService>().pushReplacement(context, LoginPage());
              },
              child: Text(
                context.tr("auth_page.sign_in"),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: appColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator({required double screenHeight}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: _passwordController.text.isEmpty
                        ? Colors.grey[800]
                        : passwordStrengthColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: _entropy < 30
                        ? Colors.grey[800]
                        : passwordStrengthColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: _entropy < 50
                        ? Colors.grey[800]
                        : passwordStrengthColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: _entropy < 70
                        ? Colors.grey[800]
                        : passwordStrengthColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        if (_passwordController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  context.tr(
                    "auth_page.psw_strength",
                    namedArgs: {
                      "passwordStrength": passwordStrength,
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
