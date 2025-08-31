import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/game_icons.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/features/Profile/presentation/pages/user_profile_page.dart';
import 'package:linkup/core/presentation/widgets/smth_went_wrong.dart';
import 'package:linkup/features/Search%20User/presentation/bloc/filter_users_bloc.dart';

class SearchUserPage extends StatefulWidget {
  const SearchUserPage({super.key});

  @override
  State<SearchUserPage> createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FilterUsersBloc>().add(GetAllUsers());
  }

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),
            _buildAppBar(appColors),
            const SizedBox(height: 20),
            BlocBuilder<FilterUsersBloc, FilterUsersState>(
              builder: (context, state) {
                if (state is GettingAllUsers) {
                  return const CircularProgressIndicator();
                } else if (state is GettingAllUsersFailure) {
                  return const SmthWentWrong();
                } else if (state is SearchedUsers) {
                  if (state.filteredUsers.isEmpty) {
                    return _buildEmptySearchListIndicator();
                  } else {
                    return _buildUsersList(
                      appColors,
                      itemCount: state.filteredUsers.length,
                      users: state.filteredUsers,
                    );
                  }
                } else if (state is GotAllUsers) {
                  if (state.allUsers.isEmpty) {
                    return _buildEmptyListIndicator();
                  } else {
                    return _buildUsersList(
                      appColors,
                      itemCount: state.allUsers.length,
                      users: state.allUsers,
                    );
                  }
                } else {
                  return const SmthWentWrong();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(AppColors appColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              onChanged: (value) {
                context.read<FilterUsersBloc>().add(
                      SearchUsersEvent(query: value),
                    );
              },
              controller: _searchController,
              maxLines: 1,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: appColors.surface,
                    width: 2.0,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: appColors.secondary,
                    width: 2.0,
                  ),
                ),
                fillColor: appColors.background,
                filled: true,
                hintText: context.tr("search_user_page.search_hint"),
                hintStyle: TextStyle(
                  color: appColors.hint,
                ),
              ),
              style: TextStyle(color: appColors.secondary),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              _searchController.clear();
              context.read<FilterUsersBloc>().add(
                    const SearchUsersEvent(query: ""),
                  );
            },
            icon: const Icon(Icons.clear_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchListIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 50, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            context.tr("search_user_page.no_one"),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            context.tr("search_user_page.try"),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyListIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Iconify(
            GameIcons.dinosaur_rex,
            size: 50,
            color: Colors.grey,
          ),
          SizedBox(height: 10),
          Text(
            "There's no one there",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            "You're the first user",
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(AppColors appColors,
      {required int itemCount, required List<UserEntity> users}) {
    return Expanded(
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final UserEntity user = users[index];
          final String? profileImageUrl = user.profileImageUrl;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(
                      user: user,
                      navigatedFromChatPage: false,
                    ),
                  ),
                );
              },
              leading: profileImageUrl == null
                  ? Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: appColors.secondary,
                          width: 1.0,
                        ),
                      ),
                      child: const ClipOval(
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 40,
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 24,
                      backgroundImage: CachedNetworkImageProvider(
                        profileImageUrl,
                      ),
                    ),
              title: Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
