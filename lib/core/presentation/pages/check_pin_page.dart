import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/config/theme/theme_getter.dart';
import 'package:linkup/core/presentation/bloc/crypto/crypto_bloc.dart';
import 'package:linkup/core/presentation/widgets/filled_rounded_pin_put.dart';
import 'package:linkup/features/Profile/presentation/bloc/profile/profile_bloc.dart';

class CheckPinPage extends StatelessWidget {
  const CheckPinPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: BlocConsumer<CryptoBloc, CryptoState>(
              listener: (context, state) {
                if (state is PinIsValid) {
                  Navigator.pop(context, true);
                } else if (state is PinIsInvalid) {
                  if (kDebugMode) {
                    print("Pin is invalid");
                  }
                }
              },
              builder: (context, state) => Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Enter pin code",
                              style: theme.welcomeTextTheme.textStyle,
                            ),
                          ],
                        ),
                        FilledRoundedPinPut(
                          length: 4,
                          obscureText: true,
                          validator: (value) {
                            if (state is PinIsInvalid) {
                              return "Pin is incorrect";
                            }
                            return null;
                          },
                          onCompleted: (pin) {
                            final String? pinHash = context
                                .read<ProfileBloc>()
                                .cachedUserData
                                ?.privateDataEntity
                                ?.pinHash;

                            if (pinHash != null) {
                              context
                                  .read<CryptoBloc>()
                                  .add(CheckPin(data: pin, hash: pinHash));
                            }
                          },
                        ),
                        const Text(
                          "Your PIN is an additional security feature within the app.",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
