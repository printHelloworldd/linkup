import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:linkup/config/dimensions.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/config/theme/theme_getter.dart';
import 'package:linkup/core/domain/entities/user/private_data_entity.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/presentation/bloc/crypto/crypto_bloc.dart';
import 'package:linkup/core/presentation/pages/main_menu.dart';
import 'package:linkup/features/Authentication/presentation/widgets/custom_button.dart';
import 'package:linkup/features/Profile/presentation/bloc/profile/profile_bloc.dart';

class MnemonicPage extends StatefulWidget {
  const MnemonicPage({super.key});

  @override
  State<MnemonicPage> createState() => _MnemonicPageState();
}

class _MnemonicPageState extends State<MnemonicPage> {
  bool isMnemonicShowed = false;
  String _markdownData = '';
  late UserEntity currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = context.read<ProfileBloc>().cachedUserData!;

    _loadMarkdown();
  }

  // Загрузка MD файла из assets
  Future<void> _loadMarkdown() async {
    String data = await rootBundle.loadString('assets/mnemonic_alert.md');
    setState(() {
      _markdownData = data;
    });
  }

  void _copyMnemonicPhrase(AppColors appColors, String phrase) {
    FlutterClipboard.copy(phrase);

    Fluttertoast.showToast(
      msg: "Phrase copied to clipboard", // TODO: Localize
      backgroundColor: appColors.primary,
      textColor: Colors.black,
      fontSize: 14,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    double currentWidth = MediaQuery.of(context).size.width;

    return BlocBuilder<CryptoBloc, CryptoState>(
      builder: (context, state) {
        if (state is DecryptedData) {
          isMnemonicShowed = true;
        }

        return Scaffold(
          appBar: _buildAppBar(),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  isMnemonicShowed && state is DecryptedData
                      ? _buildMnemonic(
                          appColors, currentWidth, state.decryptedData)
                      : _buildAlertMessage(appColors),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      forceMaterialTransparency: true,
      centerTitle: true,
      title: Text("Step ${!isMnemonicShowed ? 1 : 2}/2"),
      leading: !isMnemonicShowed
          ? IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            )
          : Container(),
    );
  }

  Widget _buildAlertMessage(AppColors colors) {
    return Expanded(
      child: Column(
        children: [
          Expanded(child: Markdown(data: _markdownData)),
          _buildShowButton(colors),
        ],
      ),
    );
  }

  Widget _buildMnemonic(
      AppColors appColors, double currentWidth, String phrase) {
    final List<String> words = phrase.split(" ");

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
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                            "${index < 9 ? 0 : ""}${index + 1}. ${words[index]}"), // TODO: Можно просто сделать "${index + 1}"
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                TextButton.icon(
                  onPressed: () {
                    _copyMnemonicPhrase(appColors, phrase);
                  },
                  label: Text(
                    // TODO: Localize
                    "Copy phrase",
                    style: TextStyle(
                      color: appColors.secondary,
                    ),
                  ),
                  icon: Icon(
                    MingCuteIcons.mgc_copy_3_line,
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
          //         color: AppTheme.backgroundColor,
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
            onTap: () {
              context.read<ProfileBloc>().add(
                    UpdateUserEvent(
                      privateDataEntity: PrivateDataEntity(
                        edPrivateKey:
                            currentUser.privateDataEntity!.edPrivateKey,
                        xPrivateKey: currentUser.privateDataEntity!.xPrivateKey,
                        pinHash: currentUser.privateDataEntity!.pinHash,
                        encryptedMnemonic:
                            "", //? Может быть, стоит передавать null
                        isVerified: true,
                      ),
                    ),
                  );

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
        ],
      ),
    );
  }

  Widget _buildShowButton(AppColors appColors) {
    return CustomButton(
      onTap: () {
        context.read<CryptoBloc>().add(
              DecryptData(
                encryptedData: currentUser.privateDataEntity!.encryptedMnemonic,
                edPublicKey: currentUser.restrictedDataEntity!.edPublicKey,
                receiverXPublicKey:
                    currentUser.restrictedDataEntity!.xPublicKey,
                senderXPrivateKey: currentUser.privateDataEntity!.xPrivateKey,
                senderXPublicKey: currentUser.restrictedDataEntity!.xPublicKey,
                userID: currentUser.id,
              ),
            );
      },
      child: BlocBuilder<CryptoBloc, CryptoState>(
        builder: (context, state) {
          if (state is Loading) {
            return const CircularProgressIndicator();
          }
          return Row(
            children: [
              Text(
                "Show",
                style: TextStyle(
                  color: appColors.text,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Icon(
                MingCuteIcons.mgc_arrow_right_line,
                color: appColors.background,
              ),
            ],
          );
        },
      ),
    );
  }
}
