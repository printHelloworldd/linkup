import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/config/theme/theme_getter.dart';
import 'package:linkup/core/presentation/navigation_service.dart';
import 'package:linkup/core/presentation/pages/main_menu.dart';
import 'package:linkup/features/Authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:linkup/features/Authentication/presentation/pages/create%20profile%20pages/main_page.dart';
import 'package:linkup/features/Authentication/presentation/pages/reset_password_page.dart';
import 'package:linkup/features/Authentication/presentation/pages/verification_page.dart';
import 'package:linkup/features/Authentication/presentation/widgets/app_icon.dart';
import 'package:linkup/features/Authentication/presentation/widgets/custom_button.dart';
import 'package:linkup/features/Authentication/presentation/widgets/auth_textfield.dart';
import 'package:linkup/features/Authentication/presentation/widgets/o_auth_panel.dart';
import 'package:linkup/features/Authentication/presentation/widgets/or_continue_with.dart';
import 'package:linkup/injection_container.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showToast(AppColors appColors, String msg) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: appColors.primary,
      fontSize: 16,
      textColor: appColors.background,
    );
  }

  void _showWebToast(AppColors appColors, BuildContext context, String msg) {
    String text = "";
    if (msg == "Exception: invalid-credential") {
      text = context.tr("auth_page.wrong_data");
    } else if (msg == "Exception: invalid-email") {
      text = context.tr("auth_page.invalid_email");
    } else {
      text = msg;
    }

    FToast().init(context).showToast(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: appColors.primary,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: appColors.background,
              ),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;
    final AppColors appColors = theme.appColors;

    return SafeArea(
      child: Scaffold(
        backgroundColor: appColors.background,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSignedIn) {
              sl<NavigationService>()
                  .pushReplacement(context, const VerificationPage());
            }
            if (state is AuthSignedInViaGoogle) {
              sl<NavigationService>()
                  .pushReplacement(context, const MainMenu());
            }
            if (state is AuthSigningInFailure) {
              if (!kIsWeb) {
                _showToast(appColors, state.exception.toString());
              } else {
                _showWebToast(appColors, context, state.exception.toString());
              }
            }
            if (state is AuthSigningInViaGoogleFailure) {
              if (!kIsWeb) {
                _showToast(appColors, state.exception.toString());
              } else {
                _showWebToast(appColors, context, state.exception.toString());
              }
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              double screenHeight = constraints.maxHeight;
              double screenWidth = constraints.maxWidth;

              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.05),

                      // App icon
                      const AppIcon(
                        iconPath: "assets/icons/link.png",
                        size: 96,
                      ),

                      SizedBox(height: screenHeight * 0.05),

                      _buildWelcomeText(theme, appColors, context),

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
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                sl<NavigationService>()
                                    .push(context, ResetPasswordPage());
                              },
                              child: Text(
                                context.tr("auth_page.forgot_psw"),
                                style: TextStyle(
                                  color: appColors.secondary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Sign in button
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
                              context.read<AuthBloc>().add(
                                    SignIn(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    ),
                                  );
                            },
                            child: Text(
                              context.tr("auth_page.sign_in"),
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

                      // OAuth buttons
                      const OAuthPanel(),
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

  Widget _buildWelcomeText(
      ThemeData theme, AppColors appColors, BuildContext context) {
    return Column(
      children: [
        Text(
          context.tr("auth_page.login_title"),
          style: theme.welcomeTextTheme.textStyle,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.tr("auth_page.login_subtitle"),
              style: TextStyle(
                fontSize: 20,
                color: appColors.secondary,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                sl<NavigationService>().pushReplacement(
                    context, const MainPage(isUserRegistered: false));
              },
              child: Text(
                context.tr("auth_page.sign_up"),
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
}
