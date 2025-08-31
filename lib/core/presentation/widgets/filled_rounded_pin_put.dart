// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/config/theme/theme_getter.dart';

class FilledRoundedPinPut extends StatefulWidget {
  final int length;
  final bool obscureText;
  final Function(String pin) onCompleted;
  final String? Function(String? value)? validator;

  const FilledRoundedPinPut({
    super.key,
    required this.length,
    required this.obscureText,
    required this.onCompleted,
    this.validator,
  });

  @override
  _FilledRoundedPinPutState createState() => _FilledRoundedPinPutState();

  @override
  String toStringShort() => 'Rounded Filled';
}

class _FilledRoundedPinPutState extends State<FilledRoundedPinPut> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  bool showError = false;

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    final length = widget.length;
    final borderColor = appColors.primary;
    final errorColor = Colors.red[800];
    final fillColor = Colors.grey[800];
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.poppins(
        fontSize: 22,
        color: appColors.primary,
      ),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return SizedBox(
      height: 68,
      child: Pinput(
        length: length,
        controller: controller,
        focusNode: focusNode,
        obscureText: widget.obscureText,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        defaultPinTheme: defaultPinTheme,
        onCompleted: (pin) => widget.onCompleted(pin),
        // validator: (pin) {
        //   return pin == '2222' ? null : 'Pin is incorrect';
        // },
        validator: (value) =>
            widget.validator != null ? widget.validator!(value) : null,
        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
        focusedPinTheme: defaultPinTheme.copyWith(
          height: 68,
          width: 64,
          decoration: defaultPinTheme.decoration!.copyWith(
            border: Border.all(color: borderColor),
          ),
        ),
        errorPinTheme: defaultPinTheme.copyWith(
          textStyle: GoogleFonts.poppins(
            fontSize: 22,
            color: errorColor,
          ),
          decoration: BoxDecoration(
            color: fillColor,
            border: Border.all(color: errorColor!),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
