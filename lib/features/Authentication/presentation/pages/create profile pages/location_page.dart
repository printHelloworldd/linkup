import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/features/Authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:linkup/core/presentation/bloc/country_city/country_city_bloc.dart';
import 'package:linkup/features/Authentication/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:linkup/core/presentation/widgets/select_city_widget.dart';
import 'package:linkup/core/presentation/widgets/select_country_widget.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;

    final countryCityBloc = context.read<CountryCityBloc>();

    return BlocListener<NavigationBloc, NavigationState>(
      listenWhen: (previous, current) => current is NavigatedToNextPage,
      listener: (context, state) {
        if (state is NavigatedToNextPage) {
          context.read<AuthBloc>().add(
                UpdateUserData(
                  country: countryCityBloc.selectedCountry,
                  city: countryCityBloc.selectedCity,
                ),
              );
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.tr("location_page.title"),
                  style: theme.welcomeTextTheme.textStyle,
                ),
                const SizedBox(height: 32),
                SelectCountryWidget(
                  countries: countryCityBloc.cachedCountries,
                ),
                const SizedBox(height: 20),
                BlocBuilder<CountryCityBloc, CountryCityState>(
                  builder: (context, state) {
                    if (countryCityBloc.selectedCountry != "") {
                      return const SelectCityWidget();
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
