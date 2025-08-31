import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/features/Authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:linkup/features/Authentication/presentation/widgets/o_auth_button.dart';

class OAuthPanel extends StatelessWidget {
  const OAuthPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // google button
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSigningInViaGoogle) {
              return OAuthButton(
                onTap: () {},
                child: const CircularProgressIndicator(),
              );
            }
            return OAuthButton(
              onTap: () {
                context.read<AuthBloc>().add(SignInViaGoogle());
              },
              child: Image.asset(
                "assets/logo-icons/google.png",
                height: 40,
              ),
            );
          },
        ),

        // const SizedBox(width: 25),

        // // facebook button
        // OAuthButton(
        //   onTap: () {},
        //   iconPath: "assets/logo-icons/facebook.png",
        // ),

        // const SizedBox(width: 25),

        // // apple button
        // OAuthButton(
        //   onTap: () {},
        //   iconPath: "assets/logo-icons/apple-logo.png",
        // ),
      ],
    );
  }
}
