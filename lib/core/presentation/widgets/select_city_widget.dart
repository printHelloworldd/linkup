// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/get_utils.dart';

import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/core/domain/entities/city_entity.dart';
import 'package:linkup/core/presentation/bloc/country_city/country_city_bloc.dart';

import 'popup card/custom_rect_tween.dart';
import 'popup card/hero_dialog_route.dart';

class SelectCityWidget extends StatelessWidget {
  const SelectCityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;
    String selectedCity = "";

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(HeroDialogRoute(builder: (context) {
          return const _SelectCityWidget();
        }));
      },
      child: Hero(
        tag: _heroSelectCity,
        createRectTween: (begin, end) {
          return CustomRectTween(begin: begin!, end: end!);
        },
        child: Material(
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[500]!,
                  width: 2.0,
                ),
              ),
            ),
            child: BlocBuilder<CountryCityBloc, CountryCityState>(
              builder: (context, state) {
                selectedCity = context.read<CountryCityBloc>().selectedCity;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCity == ""
                          ? context.tr("city_widget.select_city")
                          : selectedCity,
                      style: TextStyle(
                        color: selectedCity.isEmpty
                            ? appColors.hint
                            : appColors.secondary,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down_rounded)
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

const String _heroSelectCity = 'select-city-hero';

class _SelectCityWidget extends StatefulWidget {
  const _SelectCityWidget();

  @override
  State<_SelectCityWidget> createState() => _SelectCityWidgetState();
}

class _SelectCityWidgetState extends State<_SelectCityWidget> {
  final TextEditingController _searchController = TextEditingController();

  List<CityEntity> _foundCities = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCities);
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _foundCities = context.read<CountryCityBloc>().cachedCities;
      } else {
        _foundCities = context
            .read<CountryCityBloc>()
            .cachedCities
            .where((city) => city.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCities);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: _heroSelectCity,
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
                    _buildSearchPanel(appColors),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: BlocBuilder<CountryCityBloc, CountryCityState>(
                        builder: (context, state) {
                          final bloc = context.read<CountryCityBloc>();
                          if (state is GettingCities) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is GetCitiesFailure) {
                            return Text(context.tr("core.smth_went_wrong"));
                          }
                          if (bloc.cachedCities.isNotEmpty) {
                            if (_foundCities.isEmpty) {
                              _foundCities = bloc.cachedCities;
                            }

                            return _buildCitiesList(bloc);
                          } else {
                            return Center(
                              child: Text(context.tr("city_widget.no_cities")),
                            );
                          }
                        },
                      ),
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

  Widget _buildSearchPanel(AppColors appColors) {
    return Row(
      children: [
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
              fillColor: appColors.background,
              filled: true,
              hintText: context.tr("city_widget.search"),
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
            if (_searchController.text.isEmpty) {
              Navigator.pop(context);
            } else {
              _searchController.clear();
            }
          },
          icon: const Icon(Icons.clear_rounded),
        ),
      ],
    );
  }

  Widget _buildCitiesList(CountryCityBloc bloc) {
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: _foundCities.length,
      itemBuilder: (context, index) {
        final city = _foundCities[index];

        return ListTile(
          title: Text(
            city.name,
          ),
          onTap: () {
            bloc.selectedCity = city.name;

            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
