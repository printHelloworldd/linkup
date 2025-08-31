import 'package:clipboard/clipboard.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:linkup/config/dimensions.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/config/theme/theme_getter.dart';
import 'package:linkup/core/domain/entities/user/private_data_entity.dart';
import 'package:linkup/core/domain/entities/user/restricted_data_entity.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/presentation/bloc/crypto/crypto_bloc.dart';
import 'package:linkup/core/presentation/pages/check_pin_page.dart';
import 'package:linkup/core/presentation/pages/main_menu.dart';
import 'package:linkup/features/Authentication/presentation/widgets/custom_button.dart';
import 'package:linkup/features/Profile/presentation/bloc/profile/profile_bloc.dart';

class SetMnemonicPage extends StatefulWidget {
  const SetMnemonicPage({super.key});

  @override
  State<SetMnemonicPage> createState() => _SetMnemonicPageState();
}

class _SetMnemonicPageState extends State<SetMnemonicPage> {
  List<String> words = List.filled(12, '');

  Future<List<String>> _pasteMnemonicPhrase() async {
    final String phrase = await FlutterClipboard.paste();

    return phrase.trim().split(" ");
  }

  void _showProgressDialog(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: appColors.background,
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
    // final AppColors appColors =
    //     context.theme.appColors;

    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // backgroundColor: appColors.background,
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
                // style: TextStyle(
                //   color: appColors.secondary,
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
    double currentWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: BlocListener<CryptoBloc, CryptoState>(
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

                _showAnimation(context);
              }
              if (state is GeneratingDataFailure) {
                // TODO: Show an error
              }
            },
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildMnemonic(currentWidth),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      forceMaterialTransparency: true,
      centerTitle: true,
      title: Text("Recovery phrase"),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
    );
  }

  Widget _buildMnemonic(double currentWidth) {
    final AppColors appColors = context.theme.appColors;

    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                GridView.builder(
                  itemCount: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: currentWidth < mobileWidth ? 2 : 5,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 4,
                  ),
                  itemBuilder: (context, index) {
                    String hintText = "${index + 1}";

                    if (index < words.length && words[index].isNotEmpty) {
                      hintText = "${index + 1} ${words[index]}";
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: TextField(
                          key: ValueKey(hintText),
                          onChanged: (value) {
                            setState(() {
                              words[index] = value.trim();
                            });
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: hintText,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                TextButton.icon(
                  onPressed: () async {
                    final List<String> pastedWords =
                        await _pasteMnemonicPhrase();
                    setState(() {
                      words = pastedWords;
                    });
                  },
                  label: Text(
                    // TODO: Localize
                    "Paste phrase",
                    style: TextStyle(
                      color: appColors.secondary,
                    ),
                  ),
                  icon: Icon(
                    MingCuteIcons.mgc_paste_line,
                    color: appColors.secondary,
                  ),
                  style: ButtonStyle(
                    overlayColor: WidgetStatePropertyAll(
                      Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // AuthButton(
          //   onTap: () {},
          //   child: const Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Icon(
          //         MingCuteIcons.mgc_qrcode_2_fill,
          //         color: appColors.background,
          //       ),
          //       Text(
          //         "Generate QR-code",
          //         style: TextStyle(
          //           color: AppTheme.textColor,
          //           fontSize: 16,
          //         ),
          //       ),
          //       SizedBox(width: 16),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 16),
          CustomButton(
            onTap: () async {
              final bool result = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return const CheckPinPage();
              }));

              if (result && context.mounted) {
                context.read<CryptoBloc>().add(
                      GenerateData(seedPhrase: words.join(" ")),
                    );
              }
            },
            child: BlocBuilder<CryptoBloc, CryptoState>(
              builder: (context, state) {
                if (state is GeneratingData) {
                  return const CircularProgressIndicator();
                }
                return Row(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
