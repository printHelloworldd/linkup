import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:linkup/config/dimensions.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/core/presentation/navigation_service.dart';
import 'package:linkup/core/presentation/widgets/filled_rounded_pin_put.dart';
import 'package:linkup/features/Authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:linkup/features/Authentication/presentation/pages/verification_page.dart';
import 'package:linkup/injection_container.dart';

class PinPage extends StatelessWidget {
  const PinPage({super.key});

  void _showFailureAlert(BuildContext context) {
    // final AppColors appColors =
    //     context.theme.appColors;

    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // backgroundColor: appColors.background,
          title: const Text("Failed to create account"),
          content: const Text("Try again later or contact support"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Ok",
                // style: TextStyle(
                //   color: AppTheme.secondaryColor,
                // ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;

    final currentWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is CreatedUser) {
                  sl<NavigationService>()
                      .pushReplacement(context, const VerificationPage());
                } else if (state is CreatingUserFailure) {
                  _showFailureAlert(context);
                }
              },
              builder: (context, state) {
                if (state is CreatingUser) {
                  if (currentWidth < mobileWidth) {
                    return Center(
                      child: _buildLoadingAnimation(),
                    );
                  } else {
                    return Center(
                      child: SizedBox(
                          height: 200,
                          width: 200,
                          child: _buildLoadingAnimation()),
                    );
                  }
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Almost done!",
                          style: theme.welcomeTextTheme.textStyle,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "You're almost there! Create a 4-digit PIN. It's used to protect your chats and important actions in the app.",
                        ),
                      ],
                    ),
                    FilledRoundedPinPut(
                      length: 4,
                      obscureText: true,
                      onCompleted: (pin) {
                        context.read<AuthBloc>().add(CreateUser(pin: pin));
                      },
                    ),
                    const Text(
                      "Your PIN is an additional security feature within the app.",
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    // return Lottie.asset(
    //   "assets/animations/loading_animation.json",
    //   repeat: true,
    //   width: 256,
    //   height: 256,
    // );

    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
