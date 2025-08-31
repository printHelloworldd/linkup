import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:lottie/lottie.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/core/domain/entities/user/private_data_entity.dart';
import 'package:linkup/core/domain/entities/user/restricted_data_entity.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/presentation/bloc/crypto/crypto_bloc.dart';
import 'package:linkup/core/presentation/pages/check_pin_page.dart';
import 'package:linkup/core/presentation/pages/main_menu.dart';
import 'package:linkup/features/Authentication/presentation/widgets/custom_button.dart';
import 'package:linkup/features/Profile/presentation/bloc/profile/profile_bloc.dart';

class MobileScannerPage extends StatefulWidget {
  const MobileScannerPage({super.key});

  @override
  State<MobileScannerPage> createState() => _MobileScannerPageState();
}

class _MobileScannerPageState extends State<MobileScannerPage> {
  bool torch = false;

  void _showProgressDialog(BuildContext context) {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              // backgroundColor: AppTheme.backgroundColor,
              title: Text(context.tr("scanner_page.progress")),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Generating deterministic data"),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAnimation(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // backgroundColor: AppTheme.backgroundColor,
          title: Text(context.tr("scanner_page.imported")),
          content: Lottie.asset(
            "assets/animations/Animation - done.json",
            repeat: false,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MainMenu()),
                  (route) => false, // Удаляет все предыдущие экраны
                );
              },
              child: Text(
                context.tr("core.done"),
                style: TextStyle(
                  color: appColors.secondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: BlocConsumer<CryptoBloc, CryptoState>(
        listener: (context, state) {
          if (state is GeneratedData) {
            final UserEntity cachedUser =
                context.read<ProfileBloc>().cachedUserData!;

            context.read<ProfileBloc>().add(
                  UpdateUserEvent(
                    privateDataEntity: PrivateDataEntity(
                      edPrivateKey: state.cryptographyData.edPrivateKey,
                      xPrivateKey: state.cryptographyData.xPrivateKey,
                      encryptedMnemonic: "",
                      pinHash: cachedUser.privateDataEntity!.pinHash,
                      isVerified: cachedUser.privateDataEntity!.isVerified,
                    ),
                    restrictedDataEntity: RestrictedDataEntity(
                      edPublicKey: state.cryptographyData.edPublicKey!,
                      xPublicKey: state.cryptographyData.xPublicKey!,
                      fcmToken: cachedUser.restrictedDataEntity?.fcmToken,
                    ),
                    cryptographyEntity: state.cryptographyData,
                  ),
                );
          }
          if (state is GeneratingDataFailure) {
            // TODO: Show an error
          }
        },
        builder: (context, state) {
          if (state is GeneratingData) {
            return const CircularProgressIndicator();
          } else if (state is GeneratedData) {
            return Column(
              children: [
                Expanded(
                  child: Lottie.asset(
                    "assets/animations/Animation - done.json",
                    repeat: false,
                  ),
                ),
                CustomButton(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const MainMenu()),
                      (route) => false, // Удаляет все предыдущие экраны
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        MingCuteIcons.mgc_check_2_fill,
                        color: appColors.background,
                      ),
                      Text(
                        "Done",
                        style: TextStyle(
                          color: appColors.text,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            );
          }
          return MobileScanner(
            // scanWindow: Rect.fromCenter(
            //   center: const Offset(200, 400), // Координаты центра
            //   width: 250, // Ширина области сканирования
            //   height: 250, // Высота области сканирования
            // ),
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
              formats: [BarcodeFormat.qrCode], // Только QR-коды
              // torchEnabled: torch,
              facing: CameraFacing.back,
            ),
            onDetect: (barcodes) async {
              for (var barcode in barcodes.barcodes) {
                if (barcode.rawValue != null) {
                  if (barcode.rawValue!.isNotEmpty) {
                    // _showProgressDialog(context);

                    final bool result = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const CheckPinPage();
                    }));

                    if (result && context.mounted) {
                      context.read<CryptoBloc>().add(
                            GenerateData(seedPhrase: barcode.rawValue!),
                          );
                    }
                  }
                }
              }
            },
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(context.tr("scanner_page.scan")),
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(MingCuteIcons.mgc_left_line),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      // actions: [
      //   IconButton(
      //     icon: Icon(torch ? Icons.flash_on : Icons.flash_off),
      //     onPressed: () {
      //       setState(() {
      //         torch = !torch;
      //       });
      //       // controller.toggleTorch();
      //     },
      //   )
      // ],
    );
  }
}
