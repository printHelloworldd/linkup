import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/core/domain/entities/user/private_data_entity.dart';
import 'package:linkup/core/domain/entities/user/restricted_data_entity.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/presentation/bloc/crypto/crypto_bloc.dart';
import 'package:linkup/core/presentation/pages/mobile_scanner_page.dart';
import 'package:linkup/core/presentation/pages/set_mnemonic_page.dart';
import 'package:linkup/features/Profile/presentation/bloc/profile/profile_bloc.dart';

class EmptyDataDialog {
  static void showAlertDialog(BuildContext context, bool isVerified) {
    final AppColors appColors = context.theme.appColors;

    if (isVerified) {
      _showToVerifiedUser(appColors, context);
    } else {
      _showToUnverifiedUser(appColors, context);
    }
  }

  static void _showGenerationWarning(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Generate new Cryptography Data"),
            actionsAlignment: MainAxisAlignment.center,
            content: BlocConsumer<CryptoBloc, CryptoState>(
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

                Navigator.pop(context);
                Navigator.pop(context);
              }
            }, builder: (context, state) {
              if (state is GeneratingData) {
                return const CircularProgressIndicator();
              } else if (state is GeneratedData) {
                // TODO: Show animation
              }
              return Text(
                "Are you sure you want to generate new data. You won't have acces to messages",
              );
            }),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: appColors.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<CryptoBloc>().add(const GenerateData());
                },
                child: Text(
                  "Yes",
                  style: TextStyle(
                    color: appColors.primary,
                  ),
                ),
              ),
            ],
          );
        });
  }

  static void _showToVerifiedUser(AppColors appColors, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Приватные данные не найдены"),
        actionsAlignment: MainAxisAlignment.center,
        content: Text(
          "Похоже, на этом устройстве нет сохранённых приватных данных. \n Вы можете восстановить доступ одним из следующих способов: \n\n - Отсканируйте QR-код с другого устройства, где данные уже есть. Профиль -> Настройки -> Сгенерировать QR-код \n - Введите или вставьте сид-фразу вручную ввиде слов или QR-кода. \n\n Если вы не восстановите данные, доступ к чатам будет недоступен.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Cancel",
              style: TextStyle(
                color: appColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MobileScannerPage(),
                ),
              );
            },
            child: Text(
              "Scan QR-code",
              style: TextStyle(
                color: appColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const SetMnemonicPage();
              }));
            },
            child: Text(
              "Enter seed phrase",
              style: TextStyle(
                color: appColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _showGenerationWarning(context);
            },
            child: Text(
              "Generate new data",
              style: TextStyle(
                color: appColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showToUnverifiedUser(AppColors appColors, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Приватные данные не найдены"),
        actionsAlignment: MainAxisAlignment.center,
        content: Text(
          "Похоже, на этом устройстве нет сохранённых приватных данных. \n Вы можете восстановить доступ одним из следующих способов: \n\n - Отсканируйте QR-код с другого устройства, где данные уже есть. Профиль -> Настройки -> Сгенерировать QR-код \n\n Если вы не восстановите данные, доступ к чатам будет недоступен.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Cancel",
              style: TextStyle(
                color: appColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MobileScannerPage(),
                ),
              );
            },
            child: Text(
              "Scan QR-code",
              style: TextStyle(
                color: appColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _showGenerationWarning(context);
            },
            child: Text(
              "Generate new data",
              style: TextStyle(
                color: appColors.primary,
              ),
            ),
          ),
          //! User cannot recover data from server if he does not have X key pair and ED key pair
          // TextButton(
          //   onPressed: () {},
          //   child: const Text(
          //     "Recover from server",
          //     style: TextStyle(
          //       color: AppTheme.primaryColor,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
