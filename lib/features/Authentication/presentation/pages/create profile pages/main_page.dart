// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:linkup/features/Authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:linkup/features/Authentication/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:linkup/features/Authentication/presentation/pages/create%20profile%20pages/bio_page.dart';
import 'package:linkup/features/Authentication/presentation/pages/create%20profile%20pages/hobby_page.dart';
import 'package:linkup/features/Authentication/presentation/pages/create%20profile%20pages/location_page.dart';
import 'package:linkup/features/Authentication/presentation/pages/create%20profile%20pages/profile_picture_page.dart';
import 'package:linkup/features/Authentication/presentation/pages/pin_page.dart';
import 'package:linkup/features/Authentication/presentation/pages/registration_page.dart';

class MainPage extends StatefulWidget {
  final bool isUserRegistered;

  const MainPage({
    super.key,
    required this.isUserRegistered,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _pageNotifier = ValueNotifier<int>(0);

  late FToast fToast;

  @override
  void initState() {
    super.initState();

    fToast = FToast();
    // if you want to use context from globally instead of content we need to pass navigatorKey.currentContext!
    fToast.init(context);

    // TODO: Удалить слушателя и переместить логику вызова ивента в onPageChanged
    // Следим за изменением страницы
    _pageController.addListener(() {
      int newPage = _pageController.page?.round() ?? 0;

      if (_pageNotifier.value != newPage) {
        _pageNotifier.value = newPage;

        context.read<NavigationBloc>().add(NavigateToNextPage());
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageNotifier.dispose();
    super.dispose();
  }

  void _showToast() {
    Fluttertoast.showToast(
      msg: context.tr("main_page.warning"),
      backgroundColor: Colors.red[600],
      fontSize: 16,
    );
  }

  void _showWebToast() {
    FToast().showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.red[600],
        ),
        child: Text(
          context.tr("main_page.warning"),
          style: const TextStyle(
            fontSize: 16,
            // color: textColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, NavigationState>(
      listenWhen: (previous, current) => current is OnFinishedUserRegistration,
      listener: (context, state) {
        if (state is OnFinishedUserRegistration) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) {
              if (widget.isUserRegistered) {
                return const PinPage();
              } else {
                return const RegistrationPage();
              }
            }),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (value) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  children: [
                    BioPage(isUserLoggedIn: widget.isUserRegistered),
                    const HobbyPage(),
                    const LocationPage(),
                    const ProfilePicturePage(),
                  ],
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLeftButton(),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 4,
                  effect: const SwapEffect(
                    activeDotColor: Color(0xFFc0f7a6),
                    dotColor: Color(0xFFf6f6f6),
                    dotHeight: 18,
                    dotWidth: 18,
                    spacing: 16,
                  ),
                ),
                _buildRightButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftButton() {
    final navigationBloc = context.read<NavigationBloc>();

    return Positioned(
      left: 0,
      child: ValueListenableBuilder<int>(
        valueListenable: _pageNotifier,
        builder: (context, page, child) {
          return page == 0
              ? Container()
              : IconButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );

                    navigationBloc.add(NavigateToNextPage());
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 24,
                  ),
                  highlightColor: Colors.transparent,
                );
        },
      ),
    );
  }

  Widget _buildRightButton() {
    final authBloc = context.read<AuthBloc>();
    final navigationBloc = context.read<NavigationBloc>();

    return Positioned(
      right: 0,
      child: ValueListenableBuilder<int>(
        valueListenable: _pageNotifier,
        builder: (context, page, child) {
          return page == 3
              ? IconButton(
                  onPressed: () {
                    if (authBloc.user.fullName != "" &&
                        authBloc.user.hobbies.isNotEmpty) {
                      navigationBloc.add(OnFinishUserRegistration());
                    } else {
                      if (!kIsWeb) {
                        _showToast();
                      } else {
                        _showWebToast();
                      }
                    }
                  },
                  icon: const Icon(
                    Icons.done_rounded,
                    size: 24,
                  ),
                  highlightColor: Colors.transparent,
                )
              : IconButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );

                    navigationBloc.add(NavigateToNextPage());
                  },
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 24,
                  ),
                  highlightColor: Colors.transparent,
                );
        },
      ),
    );
  }
}
