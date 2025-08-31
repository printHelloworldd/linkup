// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/config/theme/theme_getter.dart';
import 'package:linkup/core/domain/entities/country_entity.dart';
import 'package:linkup/core/presentation/bloc/country_city/country_city_bloc.dart';

import 'popup card/custom_rect_tween.dart';
import 'popup card/hero_dialog_route.dart';

/// {@template add_todo_button}
/// Button to add a new [Todo].
///
/// Opens a [HeroDialogRoute] of [_SelectCountryWidget].
///
/// Uses a [Hero] with tag [_heroAddTodo].
/// {@endtemplate}
class SelectCountryWidget extends StatelessWidget {
  /// {@macro add_todo_button}
  const SelectCountryWidget({
    super.key,
    required this.countries,
    this.userCountry,
  });
  final List<CountryEntity> countries;
  final String? userCountry;

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    String selectedCountry = userCountry ?? "";

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(HeroDialogRoute(builder: (context) {
          return _SelectCountryWidget(countries);
        }));
      },
      child: Hero(
        tag: _heroSelectCountry,
        createRectTween: (begin, end) {
          return CustomRectTween(begin: begin!, end: end!);
        },
        child: Material(
          // color: AppTheme.backgroundColor,
          elevation: 2,
          // shape:
          //     RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 48,
            decoration: BoxDecoration(
              color: appColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border(
                bottom: BorderSide(
                  color: appColors.surfaceHighlight,
                  width: 2.0,
                ),
              ),
            ),
            child: BlocBuilder<CountryCityBloc, CountryCityState>(
              builder: (context, state) {
                selectedCountry =
                    context.read<CountryCityBloc>().selectedCountry;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCountry == ""
                          ? context.tr("country_widget.select")
                          : selectedCountry,
                      style: TextStyle(
                        color: selectedCountry.isEmpty
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

/// Tag-value used for the add todo popup button.
const String _heroSelectCountry = 'select-country-hero';

/// {@template add_todo_popup_card}
/// Popup card to add a new [Todo]. Should be used in conjuction with
/// [HeroDialogRoute] to achieve the popup effect.
///
/// Uses a [Hero] with tag [_heroAddTodo].
/// {@endtemplate}
class _SelectCountryWidget extends StatefulWidget {
  /// {@macro add_todo_popup_card}
  const _SelectCountryWidget(
    this.countries,
  );
  final List<CountryEntity> countries;

  @override
  State<_SelectCountryWidget> createState() => _SelectCountryWidgetState();
}

class _SelectCountryWidgetState extends State<_SelectCountryWidget> {
  final TextEditingController _searchController = TextEditingController();

  List<CountryEntity> _foundCountries = [];

  @override
  void initState() {
    super.initState();
    context.read<CountryCityBloc>().add(GetCountries());
    // _foundCountries = widget.countries;
    _searchController.addListener(_filterCountries);
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _foundCountries = context.read<CountryCityBloc>().cachedCountries;
      } else {
        _foundCountries = context
            .read<CountryCityBloc>()
            .cachedCountries
            .where((country) => country.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCountries);
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
          tag: _heroSelectCountry,
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

                          if (state is GettingCountries) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is GetCountriesFailure) {
                            return Text(context.tr("core.smth_went_wrong"));
                          }
                          if (_foundCountries.isEmpty) {
                            _foundCountries = bloc.cachedCountries;
                          }

                          return _buildCountriesList(bloc);
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
              hintText: context.tr("country_widget.search"),
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

  Widget _buildCountriesList(CountryCityBloc bloc) {
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: _foundCountries.length,
      itemBuilder: (context, index) {
        final country = _foundCountries[index];

        return ListTile(
          title: Text(
            "${country.emoji}   ${country.name} (${country.native})",
          ),
          onTap: () {
            bloc.selectedCountry = country.name;

            bloc.add(GetCities(querry: country.iso2));

            bloc.selectedCity = "";
            bloc.cachedCities.clear();

            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
