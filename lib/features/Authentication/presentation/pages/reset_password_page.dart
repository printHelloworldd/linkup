import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/features/Authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:linkup/features/Authentication/presentation/widgets/custom_button.dart';
import 'package:linkup/features/Authentication/presentation/widgets/auth_textfield.dart';

class ResetPasswordPage extends StatelessWidget {
  ResetPasswordPage({super.key});

  final TextEditingController _textEditingController = TextEditingController();

  void _resetPassword(BuildContext context) {
    try {
      context.read<AuthBloc>().add(
            SendPasswordResetEmail(
              email: _textEditingController.text.trim(),
            ),
          );

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(context.tr("reset_psw_page.sent")),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(e.message.toString()),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(context.tr("reset_psw_page.how_to")),
              const SizedBox(height: 12),
              AuthTextfield(
                controller: _textEditingController,
                obscureText: false,
                hintText: context.tr("core.email"),
              ),
              const SizedBox(height: 16),
              CustomButton(
                onTap: () => _resetPassword(context),
                child: Text(
                  context.tr("reset_psw_page.reset"),
                  style: TextStyle(
                    color: context.theme.appColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
