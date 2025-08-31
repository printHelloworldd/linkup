// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:linkup/config/dimensions.dart';

import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/presentation/bloc/crypto/crypto_bloc.dart';
import 'package:linkup/core/presentation/pages/check_pin_page.dart';
import 'package:linkup/core/presentation/widgets/popup%20card/custom_rect_tween.dart';
import 'package:linkup/core/presentation/widgets/popup%20card/hero_dialog_route.dart';
import 'package:linkup/features/Profile/presentation/bloc/profile/profile_bloc.dart';

class QrCodeWidget extends StatelessWidget {
  const QrCodeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return Hero(
      tag: _hero,
      createRectTween: (begin, end) {
        return CustomRectTween(begin: begin!, end: end!);
      },
      child: GestureDetector(
        onTap: () async {
          final bool result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) {
            return const CheckPinPage();
          }));

          if (result && context.mounted) {
            Navigator.of(context).push(HeroDialogRoute(builder: (context) {
              return const _QrCodeWidget();
            }));
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          decoration: BoxDecoration(
            color: appColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(MingCuteIcons.mgc_qrcode_2_line),
              const SizedBox(width: 10),
              Text(
                context.tr("qr_code_widget.btn_text"),
                style: TextStyle(
                  color: appColors.secondary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const String _hero = 'qr-code-hero';

class _QrCodeWidget extends StatefulWidget {
  const _QrCodeWidget();
  @override
  State<_QrCodeWidget> createState() => _QrCodeWidgetState();
}

class _QrCodeWidgetState extends State<_QrCodeWidget> {
  late bool isPrivateDataEmpty;

  @override
  void initState() {
    super.initState();

    final UserEntity userData = context.read<ProfileBloc>().cachedUserData!;
    isPrivateDataEmpty =
        UserEntity.isPrivateDataEmpty(userData.privateDataEntity);

    context.read<CryptoBloc>().add(DecryptData(
          encryptedData: userData.privateDataEntity!.encryptedMnemonic,
          edPublicKey: userData.restrictedDataEntity!.edPublicKey,
          receiverXPublicKey: userData.restrictedDataEntity!.xPublicKey,
          senderXPrivateKey: userData.privateDataEntity!.xPrivateKey,
          senderXPublicKey: userData.restrictedDataEntity!.xPublicKey,
          userID: userData.id,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;

    final AppColors appColors = context.theme.appColors;

    return PopScope(
      canPop: true,
      // onPopInvoked: (didPop) {
      //   if (didPop) {
      //     context.read<CipherBloc>().add(ResetStateEvent());

      //     setState(() {
      //       qrCodeGenerated = false;
      //       keyParts.clear();
      //       data = "";
      //       eteration = 1;
      //     });
      //   }
      // },
      child: KeyboardAvoider(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Hero(
              tag: _hero,
              createRectTween: (begin, end) {
                return CustomRectTween(begin: begin!, end: end!);
              },
              child: Material(
                color: appColors.secondary,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: !isPrivateDataEmpty
                        ? BlocBuilder<CryptoBloc, CryptoState>(
                            builder: (context, state) {
                              if (state is Loading) {
                                return const CircularProgressIndicator();
                              } else if (state is DecryptedData) {
                                // _initQrCodeData(state.encryptedPrivateKey);

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      context.tr("qr_code_widget.title"),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: appColors.background,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: currentWidth > mobileWidth
                                          ? 400
                                          : currentWidth,
                                      child: PrettyQrView.data(
                                        data: state.decryptedData,
                                        decoration: PrettyQrDecoration(
                                          background: appColors.secondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return const Center(
                                  child: Text("Something wen wrong"),
                                );
                              }
                            },
                          )
                        : Text("There is no private data on this device"),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
