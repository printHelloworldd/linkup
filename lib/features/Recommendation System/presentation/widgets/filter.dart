import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/config/theme/theme_getter.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/presentation/widgets/popup%20card/custom_rect_tween.dart';
import 'package:linkup/core/presentation/widgets/popup%20card/hero_dialog_route.dart';
import 'package:linkup/features/Profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:linkup/features/Recommendation%20System/presentation/bloc/recommendation_system_bloc.dart';

class Filter extends StatelessWidget {
  const Filter({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: _hero,
      createRectTween: (begin, end) {
        return CustomRectTween(begin: begin!, end: end!);
      },
      child: IconButton(
        onPressed: () {
          Navigator.of(context).push(HeroDialogRoute(builder: (context) {
            return const _FilterWidget();
          }));
        },
        icon: const Icon(MingCuteIcons.mgc_filter_line),
      ),
    );
  }
}

const String _hero = 'filter-widget-hero';

class _FilterWidget extends StatefulWidget {
  const _FilterWidget();

  @override
  State<StatefulWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<_FilterWidget> {
  late final UserEntity currentUserData;
  // List<String> _locationItems = [];
  Map<String, String> _locationItems = {};
  String _locationValue = "Worldwide";

  List<String> _hobbies = [];
  String _hobbyValue = "None";

  List<String> _categories = [];
  String _categoryValue = "None";

  @override
  void initState() {
    super.initState();
    currentUserData = context.read<ProfileBloc>().cachedUserData!;

    _locationItems = {
      // "Worldwide": context.tr("filter_widget.worldwide"),
      "Worldwide": "Worldwide",
      if (currentUserData.country != null &&
          currentUserData.country!.isNotEmpty)
        "Country": currentUserData.country!,
      if (currentUserData.city != null && currentUserData.city!.isNotEmpty)
        "City": currentUserData.city!,
    };

    _hobbies = ["None"] +
        currentUserData.hobbies.map((hobby) => hobby.hobbyName).toList();

    _categories = ["None"] +
        currentUserData.hobbies
            .map((hobby) => hobby.categoryName)
            .toSet()
            .toList();
  }

  void _filterUsers() {
    context.read<RecommendationSystemBloc>().add(
          GetRecommendedUsersEvent(
            user: context.read<ProfileBloc>().cachedUserData!,
            sortValues: [_locationValue, _hobbyValue, _categoryValue],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;
    final AppColors appColors = theme.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Hero(
          tag: _hero,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: Material(
            color: appColors.background,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    //* Location filter
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            context.tr("profile_page.location"),
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: appColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: DropdownButton(
                          isExpanded: true,
                          items: _locationItems.entries.map((entry) {
                            return DropdownMenuItem(
                              value: entry.key,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(entry.value),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _locationValue = newValue!;
                            });
                          },
                          value: _locationValue,
                          borderRadius: BorderRadius.circular(10),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          iconSize: 24,
                          style: TextStyle(
                            fontSize: 16,
                            color: appColors.secondary,
                          ),
                          underline: Container(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    //* Hobby filter
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            context.tr("filter_widget.hobby"),
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: appColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: DropdownButton(
                          isExpanded: true,
                          items: _hobbies.map((String item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(item),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _hobbyValue = newValue!;
                            });
                          },
                          value: _hobbyValue,
                          borderRadius: BorderRadius.circular(10),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          iconSize: 24,
                          style: TextStyle(
                            fontSize: 16,
                            color: appColors.secondary,
                          ),
                          underline: Container(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    //* Hobby category filter
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            context.tr("filter_widget.category"),
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: appColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: DropdownButton(
                          isExpanded: true,
                          items: _categories.map((String item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(item),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _categoryValue = newValue!;
                            });
                          },
                          value: _categoryValue,
                          borderRadius: BorderRadius.circular(10),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          iconSize: 24,
                          style: TextStyle(
                            fontSize: 16,
                            color: appColors.secondary,
                          ),
                          underline: Container(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    //* Cancel and Apply buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: appColors.secondary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  context.tr("core.cancel"),
                                  style: TextStyle(
                                    color: appColors.text,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _filterUsers();

                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: theme.customButtonTheme.decoration,
                              child: Center(
                                child: Text(
                                  context.tr("core.apply"),
                                  style: TextStyle(
                                    color: appColors.text,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
