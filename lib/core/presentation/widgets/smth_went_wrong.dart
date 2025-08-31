import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SmthWentWrong extends StatelessWidget {
  const SmthWentWrong({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(context.tr("core.smth_went_wrong")),
    );
  }
}
