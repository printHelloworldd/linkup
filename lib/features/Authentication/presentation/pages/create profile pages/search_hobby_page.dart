// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/config/theme/theme_getter.dart';
import 'package:linkup/core/domain/entities/hobby_entity.dart';
import 'package:linkup/core/domain/entities/hobby_category_entity.dart';
import 'package:linkup/core/presentation/bloc/hobby/hobby_selection_cubit.dart';
import 'package:linkup/features/Authentication/presentation/widgets/neu_button.dart';
import 'package:linkup/features/Profile/presentation/provider/profile_provider.dart';

class SearchHobbyPage extends StatefulWidget {
  final List<HobbyCategoryEntity> hobbies;

  const SearchHobbyPage({
    super.key,
    required this.hobbies,
  });

  @override
  State<SearchHobbyPage> createState() => _SearchHobbyPageState();
}

class _SearchHobbyPageState extends State<SearchHobbyPage> {
  final TextEditingController _searchController = TextEditingController();

  List<HobbyEntity> _selectedHobbiesList = [];

  List<HobbyCategoryEntity> _foundHobbies = [];

  @override
  void initState() {
    super.initState();
    _foundHobbies = widget.hobbies;
    _searchController.addListener(_filterHobbies);
    _selectedHobbiesList =
        Provider.of<ProfileProvider>(context, listen: false).userHobbies;
  }

  void _filterHobbies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _foundHobbies = widget.hobbies;
      } else {
        _foundHobbies = widget.hobbies
            .map((category) => HobbyCategoryEntity(
                  categoryName: category.categoryName,
                  hobbiesList: category.hobbiesList
                      .where((hobby) =>
                          hobby.hobbyName.toLowerCase().contains(query))
                      .toList(),
                ))
            .where((category) => category.hobbiesList.isNotEmpty)
            .toList();
      }
    });
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
  void dispose() {
    _searchController.removeListener(_filterHobbies);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildAppBar(),
            Expanded(
              child: _buildHobbiesGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final AppColors appColors = context.theme.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              maxLines: 1,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey[800]!,
                    width: 2.0,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey[500]!,
                    width: 2.0,
                  ),
                ),
                fillColor: Colors.grey[850],
                filled: true,
                hintText: context.tr("search_hobby_page.hint"),
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              style: TextStyle(color: appColors.secondary),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              _searchController.clear();
            },
            icon: const Icon(Icons.clear_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildHobbiesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(25),
      itemCount: _foundHobbies.fold<int>(
          0, (sum, category) => sum + category.hobbiesList.length),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 40,
        crossAxisSpacing: 40,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final hobby = _foundHobbies
            .expand((category) => category.hobbiesList)
            .toList()[index];

        return BlocBuilder<HobbySelectionCubit, Set<HobbyEntity>>(
          builder: (context, selectedHobbies) {
            return NeuButton(
              onTap: () {
                context.read<HobbySelectionCubit>().toggleHobby(hobby);
                updateHobbies(hobby);
              },
              isButtonPressed: selectedHobbies.contains(hobby),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hobby.icon?.isNotEmpty ?? false)
                      CachedNetworkImage(
                        imageUrl: hobby.icon!,
                        width: 64,
                        height: 64,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
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
            );
          },
        );
      },
    );
  }
}
