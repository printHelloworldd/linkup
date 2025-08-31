import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/config/dimensions.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/config/theme/theme_getter.dart';
import 'package:linkup/core/domain/entities/hobby_entity.dart';
import 'package:linkup/core/domain/entities/hobby_category_entity.dart';
import 'package:linkup/features/Authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:linkup/core/presentation/bloc/hobby/hobby_selection_cubit.dart';
import 'package:linkup/core/presentation/bloc/hobby/hobby_bloc.dart';
import 'package:linkup/features/Authentication/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:linkup/features/Authentication/presentation/pages/create%20profile%20pages/search_hobby_page.dart';
import 'package:linkup/features/Authentication/presentation/widgets/neu_button.dart';

class HobbyPage extends StatefulWidget {
  const HobbyPage({super.key});

  @override
  State<HobbyPage> createState() => _HobbyPageState();
}

class _HobbyPageState extends State<HobbyPage> {
  List<HobbyEntity> _selectedHobbiesList = [];
  List<HobbyCategoryEntity> _allHobbies = [];

  @override
  void initState() {
    if (context.read<HobbyBloc>().cachedHobbies == null) {
      context.read<HobbyBloc>().add(GetHobbies());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    final AppColors appColors = context.theme.appColors;

    return BlocListener<NavigationBloc, NavigationState>(
      listenWhen: (previous, current) => current is NavigatedToNextPage,
      listener: (context, state) {
        if (state is NavigatedToNextPage) {
          context.read<AuthBloc>().add(
                UpdateUserData(
                  hobbies: _selectedHobbiesList,
                ),
              );
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              _buildAppBar(),
              const SizedBox(height: 25),
              BlocBuilder<HobbyBloc, HobbyState>(
                builder: (context, state) {
                  if (state is GettingHobbies) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is GotHobbies) {
                    if (_allHobbies.isEmpty) {
                      _allHobbies = state.hobbies;
                    }

                    return _buildHobbiesByCategoriesList(
                        appColors, currentWidth);
                  } else {
                    return Center(
                      child: Text(context.tr("core.smth_went_wrong")),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final ThemeData theme = context.theme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              Text(
                context.tr("hobby_page.title"),
                style: theme.welcomeTextTheme.textStyle,
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchHobbyPage(
                        hobbies: _allHobbies,
                        // selectedHobbies: hobbiesList,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.search_rounded),
              ),
            ],
          ),
          Text(
            textAlign: TextAlign.center,
            context.tr("hobby_page.subtitle"),
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
    // return Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 10),
    //   child: Stack(
    //     children: [
    //       Column(
    //         children: [
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               Text(
    //                 context.tr("hobby_page.title"),
    //                 style: AppTheme.welcomeTextStyle,
    //               ),
    //             ],
    //           ),
    //           Text(
    //             textAlign: TextAlign.center,
    //             context.tr("hobby_page.subtitle"),
    //             style: TextStyle(
    //               fontSize: 18,
    //               color: Colors.grey[300],
    //             ),
    //           ),
    //         ],
    //       ),
    //       Positioned(
    //         right: 0,
    //         child: IconButton(
    //           onPressed: () {
    //             Navigator.push(
    //               context,
    //               MaterialPageRoute(
    //                 builder: (context) => SearchHobbyPage(
    //                   hobbies: _allHobbies,
    //                   // selectedHobbies: hobbiesList,
    //                 ),
    //               ),
    //             );
    //           },
    //           icon: const Icon(Icons.search_rounded),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  Widget _buildHobbiesByCategoriesList(
      AppColors appColors, double currentWidth) {
    return Expanded(
      child: ListView.builder(
        itemCount: _allHobbies.length,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _allHobbies[index].categoryName,
                    style: TextStyle(
                      fontSize: 22,
                      color: appColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildHobbiesGrid(index, _allHobbies, currentWidth),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHobbiesGrid(int categoryIndex,
      List<HobbyCategoryEntity> hobbiesByCategory, double currentWidth) {
    final hobbies = hobbiesByCategory[categoryIndex].hobbiesList;

    return BlocBuilder<HobbySelectionCubit, Set<HobbyEntity>>(
      builder: (context, selectedHobbies) {
        _selectedHobbiesList = selectedHobbies.toList();

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: hobbies.length,
          // padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: currentWidth < mobileWidth ? 2 : 5,
            mainAxisSpacing: 32,
            crossAxisSpacing: 32,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final hobby = hobbies[index];

            return SizedBox(
              // height: 150,
              // width: 100,
              child: NeuButton(
                onTap: () {
                  context.read<HobbySelectionCubit>().toggleHobby(hobby);
                },
                isButtonPressed: selectedHobbies.contains(hobby),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      hobby.icon!.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CachedNetworkImage(
                                imageUrl: hobby.icon!,
                                width: 64,
                                height: 64,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            )
                          : Container(),
                      Text(
                        hobby.hobbyName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget _buildHobbiesList(
  //     int categoryIndex, List<HobbyCategoryEntity> hobbiesByCategory) {
  //   final hobbies = hobbiesByCategory[categoryIndex].hobbiesList;

  //   return BlocBuilder<HobbySelectionCubit, Set<HobbyEntity>>(
  //     builder: (context, selectedHobbies) {
  //       _selectedHobbiesList = selectedHobbies.toList();

  //       return ListView.builder(
  //         physics: const NeverScrollableScrollPhysics(),
  //         shrinkWrap: true,
  //         itemCount: hobbies.length,
  //         itemBuilder: (context, index) {
  //           final hobby = hobbies[index];

  //           return Padding(
  //             padding: const EdgeInsets.only(bottom: 32),
  //             child: SizedBox(
  //               // height: 150,
  //               // width: 100,
  //               child: NeuButton(
  //                 onTap: () {
  //                   context.read<HobbySelectionCubit>().toggleHobby(hobby);
  //                 },
  //                 isButtonPressed: selectedHobbies.contains(hobby),
  //                 child: Padding(
  //                   padding:
  //                       const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //                   child: Row(
  //                     children: [
  //                       if (hobby.icon!.isNotEmpty)
  //                         Padding(
  //                           padding: const EdgeInsets.only(bottom: 12),
  //                           child: CachedNetworkImage(
  //                             imageUrl: hobby.icon!,
  //                             width: 64,
  //                             height: 64,
  //                             placeholder: (context, url) =>
  //                                 const CircularProgressIndicator(
  //                               color: AppTheme.primaryColor,
  //                             ),
  //                             errorWidget: (context, url, error) =>
  //                                 const Icon(Icons.error),
  //                           ),
  //                         ),
  //                       Text(
  //                         hobby.hobbyName,
  //                         textAlign: TextAlign.center,
  //                         style: const TextStyle(
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
}
