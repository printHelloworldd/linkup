import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/core/presentation/bloc/image%20picker/image_picker_bloc.dart';
import 'package:linkup/core/presentation/widgets/custom_text_field.dart';
import 'package:linkup/features/Authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:linkup/features/Authentication/presentation/bloc/navigation/navigation_bloc.dart';

class ProfilePicturePage extends StatefulWidget {
  const ProfilePicturePage({super.key});

  @override
  State<ProfilePicturePage> createState() => _ProfilePicturePageState();
}

class _ProfilePicturePageState extends State<ProfilePicturePage> {
  final TextEditingController _textEditingController = TextEditingController();

  Uint8List? _selectedImage;

  @override
  void initState() {
    _textEditingController.text = context.read<AuthBloc>().user.bio ?? "";
    _selectedImage = context.read<AuthBloc>().user.profileImage;
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;
    final AppColors appColors = theme.appColors;

    return BlocListener<NavigationBloc, NavigationState>(
      listenWhen: (previous, current) =>
          current is OnFinishedUserRegistration ||
          current is NavigatedToNextPage,
      listener: (context, state) {
        if (state is OnFinishedUserRegistration ||
            state is NavigatedToNextPage) {
          context.read<AuthBloc>().add(
                UpdateUserData(
                  bio: _textEditingController.text,
                  profileImage: _selectedImage,
                ),
              );
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    Text(
                      context.tr("profile_picture_page.title"),
                      style: theme.welcomeTextTheme.textStyle,
                    ),

                    const SizedBox(height: 32),

                    // Profile Picture,
                    _buildProfilePicture(appColors),

                    const SizedBox(height: 64),

                    // Short "About me",
                    _buildTextField(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture(AppColors appColors) {
    return Column(
      children: [
        BlocBuilder<ImagePickerBloc, ImagePickerState>(
          builder: (context, state) {
            if (state is PickedImageFromGallery) {
              _selectedImage = state.imageBytes;
            } else if (state is SettingImageFromGallery) {
              return const Center(
                child: SizedBox(
                  height: 64,
                  width: 64,
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return GestureDetector(
              onTap: () =>
                  context.read<ImagePickerBloc>().add(PickImageFromGallery()),
              child: _selectedImage == null
                  ? Image.asset(
                      "assets/icons/user.png",
                      height: 128,
                      width: 128,
                      color: appColors.secondary,
                    )
                  : CircleAvatar(
                      radius: 64,
                      backgroundImage: MemoryImage(
                        _selectedImage!,
                      ),
                    ),
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          context.tr("profile_picture_page.how_to"),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField() {
    return CustomTextField(
      textEditingController: _textEditingController,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      hintText: context.tr("profile_picture_page.bio"),
    );
  }
}
