import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:provider/provider.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/core/domain/entities/hobby_entity.dart';
import 'package:linkup/core/domain/entities/hobby_category_entity.dart';
import 'package:linkup/core/presentation/bloc/hobby/hobby_selection_cubit.dart';
import 'package:linkup/core/presentation/bloc/hobby/hobby_bloc.dart';
import 'package:linkup/features/Authentication/presentation/pages/create%20profile%20pages/search_hobby_page.dart';
import 'package:linkup/features/Authentication/presentation/widgets/neu_button.dart';
import 'package:linkup/features/Profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:linkup/features/Profile/presentation/provider/profile_provider.dart';

class EditHobbyPage extends StatefulWidget {
  const EditHobbyPage({super.key});

  @override
  State<EditHobbyPage> createState() => _EditHobbyPageState();
}

class _EditHobbyPageState extends State<EditHobbyPage> {
  List<HobbyEntity> _selectedHobbiesList = [];
  List<HobbyCategoryEntity> _allHobbies = [];

  @override
  void initState() {
    final cachedUserData = context.read<ProfileBloc>().cachedUserData;

    if (cachedUserData != null) {
      // Передаем сохраненные хобби в состояние Cubit
      context.read<HobbySelectionCubit>().setInitialHobbies(
            Provider.of<ProfileProvider>(context, listen: false)
                .userHobbies
                .toSet(),
          );

      _selectedHobbiesList =
          Provider.of<ProfileProvider>(context, listen: false).userHobbies;
    }

    if (context.read<HobbyBloc>().cachedHobbies == null) {
      context.read<HobbyBloc>().add(GetHobbies());
    }

    super.initState();
  }

  void updateHobbies(HobbyEntity hobby) {
    if (_selectedHobbiesList.contains(hobby)) {
      _selectedHobbiesList.remove(hobby);
    } else {
      _selectedHobbiesList.add(hobby);
    }

    context.read<ProfileProvider>().updateHobbies(_selectedHobbiesList);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return SafeArea(
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

                  return _buildHobbiesByCategoriesList(appColors);
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
    );
  }

  Widget _buildAppBar() {
    final ThemeData theme = context.theme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.tr("hobby_page.title"),
                    style: theme.textTheme.displayLarge,
                  ),
                ],
              ),
              Text(
                context.tr("hobby_page.subtitle"),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
          Positioned(
            right: 0,
            child: IconButton(
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
          ),
        ],
      ),
    );
  }

  Widget _buildHobbiesByCategoriesList(AppColors appColors) {
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
                      fontSize: 24,
                      color: appColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildHobbiesGrid(index, _allHobbies),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHobbiesGrid(
      int categoryIndex, List<HobbyCategoryEntity> hobbiesByCategory) {
    final hobbies = hobbiesByCategory[categoryIndex].hobbiesList;

    return BlocBuilder<HobbySelectionCubit, Set<HobbyEntity>>(
      builder: (context, selectedHobbies) {
        _selectedHobbiesList = selectedHobbies.toList();

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: hobbies.length,
          // padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 40,
            crossAxisSpacing: 40,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final hobby = hobbies[index];

            return SizedBox(
              height: 150,
              width: 100,
              child: NeuButton(
                onTap: () {
                  context.read<HobbySelectionCubit>().toggleHobby(hobby);
                  updateHobbies(hobby);
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
                          fontSize: 16,
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
}
