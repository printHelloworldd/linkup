// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/get_utils.dart';

import 'package:linkup/config/dimensions.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/features/Authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:linkup/features/Authentication/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:linkup/features/Authentication/presentation/pages/login_page.dart';
import 'package:linkup/features/Authentication/presentation/widgets/auth_textfield.dart';
import 'package:linkup/features/Authentication/presentation/widgets/custom_list_wheel_scroll_view.dart';

class BioPage extends StatefulWidget {
  final bool isUserLoggedIn;

  const BioPage({
    super.key,
    required this.isUserLoggedIn,
  });

  @override
  State<BioPage> createState() => _BioPageState();
}

class _BioPageState extends State<BioPage> {
  final player = AudioPlayer();
  final random = Random();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _ageTextController = TextEditingController();

  late FixedExtentScrollController _ageController;
  late FixedExtentScrollController _genderController;

  String _selectedAge = "";
  String _selectedGender = "-";

  @override
  void initState() {
    _firstNameController.text =
        context.read<AuthBloc>().user.fullName.split(" ").first;
    _secondNameController.text =
        context.read<AuthBloc>().user.fullName.split(" ").last;
    _selectedAge = context.read<AuthBloc>().user.age ?? "";
    _selectedGender = context.read<AuthBloc>().user.gender ?? "-";

    int ageInitialIndex =
        (_selectedAge == "") ? 0 : (int.parse(_selectedAge) - 13);

    int genderInitialIndex = 0;
    switch (_selectedGender) {
      case "Male":
        genderInitialIndex = 1;
        break;
      case "Female":
        genderInitialIndex = 2;
        break;
      case "Transformer":
        genderInitialIndex = 3;
        break;
    }

    _ageController = FixedExtentScrollController(initialItem: ageInitialIndex);
    _genderController =
        FixedExtentScrollController(initialItem: genderInitialIndex);
    super.initState();
  }

  void _playSound() async {
    final List<String> sounds = [
      "sounds/Transformer/ssstik (mp3cut.net).mp3",
      "sounds/Transformer/ssstik (mp3cut.net)(1).mp3",
      "sounds/Transformer/ssstik (mp3cut.net)(2).mp3",
    ];

    int randomSoundIndex = random.nextInt(3);

    await player.play(AssetSource(sounds[0]));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;
    final AppColors appColors = theme.appColors;
    final double currentWidth = MediaQuery.of(context).size.width;

    return BlocListener<NavigationBloc, NavigationState>(
      // TODO: Listen it in MainPage
      listenWhen: (previous, current) => current is NavigatedToNextPage,
      listener: (context, state) {
        if (state is NavigatedToNextPage) {
          // FocusScope.of(context).unfocus();
          context.read<AuthBloc>().add(
                UpdateUserData(
                  fullName:
                      "${_firstNameController.text} ${_secondNameController.text}"
                          .trim(),
                  age: _selectedAge,
                  gender: _selectedGender,
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
                      context.tr("bio_page.title"),
                      textAlign: TextAlign.center,
                      style: theme.welcomeTextTheme.textStyle,
                    ),
                    const SizedBox(height: 10),

                    if (!widget.isUserLoggedIn) _buildLoginLink(appColors),

                    const SizedBox(height: 32),

                    AuthTextfield(
                      key: const Key("nameField"),
                      controller: _firstNameController,
                      obscureText: false,
                      hintText: context.tr("bio_page.name"),
                    ),

                    const SizedBox(height: 20),

                    AuthTextfield(
                      controller: _secondNameController,
                      obscureText: false,
                      hintText: context.tr("bio_page.surname"),
                    ),

                    const SizedBox(height: 20),

                    // Select age
                    _buildAgeSelection(appColors, currentWidth),

                    const SizedBox(height: 20),

                    // Select gender
                    _buildGenderSelection(appColors, currentWidth),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(AppColors appColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.tr("bio_page.already_member"),
          style: TextStyle(
            fontSize: 18,
            color: appColors.secondary,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          child: Text(
            context.tr("bio_page.sign_in"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: appColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeSelection(AppColors appColors, double currentWidth) {
    const int minAge = 13;
    const int maxAge = 90;

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr("bio_page.age").split(" ").first,
              style: TextStyle(
                fontSize: 18,
                color: appColors.secondary,
              ),
            ),
            Text(
              context.tr("bio_page.age").split(" ").last,
              style: TextStyle(
                fontSize: 18,
                color: appColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        currentWidth < mobileWidth
            ? _buildAgePicker(minAge, maxAge)
            : _buildAgeTextField(appColors),
      ],
    );
  }

  Widget _buildAgeTextField(AppColors appColors) {
    return SizedBox(
      width: 150,
      child: TextField(
        controller: _ageTextController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLines: 1,
        maxLength: 3,
        buildCounter: (context,
                {required currentLength,
                required isFocused,
                required maxLength}) =>
            null,
        onChanged: (value) {
          _selectedAge = value.toString();
        },
        contextMenuBuilder: (context, editableTextState) => Container(),
        decoration: InputDecoration(
          // enabledBorder: OutlineInputBorder(
          //   borderSide: BorderSide(
          //     color: Colors.grey[800]!,
          //     width: 2.0,
          //   ),
          // ),
          // focusedBorder: OutlineInputBorder(
          //   borderSide: BorderSide(
          //     color: Colors.grey[500]!,
          //     width: 2.0,
          //   ),
          // ),
          // fillColor: AppTheme.backgroundColor,
          // filled: true,
          hintText: context.tr("bio_page.age_hint"),
          // hintStyle: TextStyle(
          //   color: Colors.grey[600],
          // ),
        ),
        style: TextStyle(color: appColors.secondary),
      ),
    );
  }

  Widget _buildAgePicker(int minAge, maxAge) {
    return CustomListWheelScrollView(
      controller: _ageController,
      height: 100,
      width: 50,
      onSelectedItemChanged: (index) {
        _selectedAge = index == 0 ? "" : (minAge + index).toString();
      },
      childCount: maxAge - minAge + 1,
      builder: (context, index) => _buildAgeItem(index, minAge),
    );
  }

  Widget _buildAgeItem(int index, int minAge) {
    final String age = index == 0 ? "---" : (minAge + index).toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Center(
        child: Text(
          age,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelection(AppColors appColors, double currentWidth) {
    // List<String> genders = [
    //   "-",
    //   context.tr("bio_page.gender.male"),
    //   context.tr("bio_page.gender.female"),
    //   context.tr("bio_page.gender.transformer"),
    // ];

    Map<String, String> genders = {
      "-": context.tr("bio_page.gender.prefer_not_to_say"),
      "Male": context.tr("bio_page.gender.male"),
      "Female": context.tr("bio_page.gender.female"),
      "Transformer": context.tr("bio_page.gender.transformer"),
    };

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr("bio_page.gender.gender").split(" ").first,
              style: TextStyle(
                fontSize: 18,
                color: appColors.secondary,
              ),
            ),
            Text(
              context.tr("bio_page.gender.gender").split(" ").last,
              style: TextStyle(
                fontSize: 18,
                color: appColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        currentWidth < mobileWidth
            ? _buildGenderPicker(genders, currentWidth)
            : _buildGendersBtns(appColors, genders),
      ],
    );
  }

  Widget _buildGendersBtns(AppColors appColors, Map<String, String> genders) {
    return Expanded(
      child: SizedBox(
        height: 24,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: genders.keys.toList().length,
          itemBuilder: (context, index) {
            String gender = genders.keys.toList()[index];

            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = gender;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: gender == _selectedGender
                            ? appColors.primary
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  child: Text(
                    genders.values.toList()[index],
                    style: TextStyle(
                      color: _selectedGender == gender
                          ? appColors.secondary
                          : Colors.grey[500],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGenderPicker(Map<String, String> genders, double currentWidth) {
    return CustomListWheelScrollView(
      controller: _genderController,
      height: 100,
      width: currentWidth < mobileWidth ? 180 : 220,
      onSelectedItemChanged: (index) {
        _selectedGender = genders.keys.toList()[index];
        // if (genders.keys.toList()[index] == "Transformer") {
        //   _playSound();
        // }
      },
      childCount: genders.length,
      builder: (context, index) =>
          _buildGenderItem(genders.values.toList()[index]),
    );
  }

  Widget _buildGenderItem(String gender) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Center(
        child: Text(
          gender,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
