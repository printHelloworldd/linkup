import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/config/theme/theme_getter.dart';
import 'package:linkup/features/Profile/presentation/pages/user_profile_page.dart';
import 'package:linkup/features/Profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:linkup/features/Recommendation%20System/presentation/bloc/recommendation_system_bloc.dart';
import 'package:linkup/features/Recommendation%20System/presentation/widgets/filter.dart';

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  @override
  void initState() {
    super.initState();
    context.read<RecommendationSystemBloc>().add(
          GetRecommendedUsersEvent(
            user: context.read<ProfileBloc>().cachedUserData!,
            sortValues: const ["Worldwide", "None", "None"],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Location Filter
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Filter(),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Recommended users
            BlocBuilder<RecommendationSystemBloc, RecommendationSystemState>(
              builder: (context, state) {
                if (state is GettingRecommendedUsers) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is GotRecommendedUsers) {
                  if (state.recommendedUsers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off,
                              size: 50, color: Colors.grey),
                          const SizedBox(height: 10),
                          Text(
                            context.tr("rec_page.no_one_found"),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.tr("rec_page.try"),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: state.recommendedUsers.length,
                        itemBuilder: (context, index) {
                          final profileImage =
                              state.recommendedUsers[index].profileImageUrl;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserProfilePage(
                                      user: state.recommendedUsers[index],
                                      navigatedFromChatPage: false,
                                    ),
                                  ),
                                );
                              },
                              leading: profileImage == null
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
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        profileImage,
                                      ),
                                    ),
                              title: Text(
                                state.recommendedUsers[index].fullName,
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
                } else if (state is GettingRecommendedUsersFailure) {
                  return Center(
                    child: Text(context.tr("core.smth_went_wrong")),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
