/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:linkup/config/theme/cubit/theme_cubit.dart';
import 'package:linkup/core/presentation/bloc/country_city/country_city_bloc.dart';
import 'package:linkup/core/presentation/bloc/crypto/crypto_bloc.dart';
import 'package:linkup/core/presentation/bloc/hobby/hobby_bloc.dart';
import 'package:linkup/core/presentation/bloc/hobby/hobby_selection_cubit.dart';
import 'package:linkup/core/presentation/bloc/image%20picker/image_picker_bloc.dart';
import 'package:linkup/core/presentation/bloc/user%20blocking/user_blocking_bloc.dart';
import 'package:linkup/features/Authentication/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:linkup/features/Chat/presentation/bloc/chat_bloc.dart';
import 'package:linkup/features/Chat/presentation/provider/chat_provider.dart';
import 'package:linkup/features/Chat/presentation/provider/chats_list_provider.dart';
import 'package:linkup/features/Profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:linkup/features/Profile/presentation/bloc/share_plus/share_plus_bloc.dart';
import 'package:linkup/features/Profile/presentation/bloc/app_version/app_version_bloc.dart';
import 'package:linkup/features/Profile/presentation/provider/profile_provider.dart';
import 'package:linkup/features/Recommendation%20System/presentation/bloc/recommendation_system_bloc.dart';
import 'package:linkup/features/Search%20User/presentation/bloc/filter_users_bloc.dart';
import 'injection_container.dart' as di;
import 'package:linkup/features/Authentication/presentation/bloc/auth/auth_bloc.dart';

List<BlocProvider> getAppBlocProviders() => [
      ..._getCoreProviders(),
      ..._getAuthFeatureProviders(),
      ..._getProfileFeatureProviders(),
      BlocProvider<ThemeCubit>(
        create: (context) => di.sl<ThemeCubit>(),
      ),
      BlocProvider<RecommendationSystemBloc>(
        create: (context) => di.sl<RecommendationSystemBloc>(),
      ),
      BlocProvider<FilterUsersBloc>(
        create: (context) => di.sl<FilterUsersBloc>(),
      ),
      BlocProvider<ChatBloc>(
        create: (context) => di.sl<ChatBloc>(),
      ),
    ];

List<BlocProvider> _getAuthFeatureProviders() => [
      BlocProvider<AuthBloc>(
        create: (context) => di.sl<AuthBloc>(),
      ),
      BlocProvider<HobbyBloc>(
        create: (context) => di.sl<HobbyBloc>(),
      ),
      BlocProvider<CountryCityBloc>(
        create: (context) => di.sl<CountryCityBloc>(),
      ),
      BlocProvider<HobbySelectionCubit>(
        create: (context) => di.sl<HobbySelectionCubit>(),
      ),
      BlocProvider<NavigationBloc>(
        create: (context) => di.sl<NavigationBloc>(),
      ),
    ];

List<BlocProvider> _getProfileFeatureProviders() => [
      BlocProvider<AppVersionBloc>(
        create: (context) => di.sl<AppVersionBloc>(),
      ),
      BlocProvider<ProfileBloc>(
        create: (context) => di.sl<ProfileBloc>(),
      ),
      BlocProvider<SharePlusBloc>(
        create: (context) => di.sl<SharePlusBloc>(),
      ),
    ];

List<BlocProvider> _getCoreProviders() => [
      BlocProvider<UserBlockingBloc>(
        create: (context) => di.sl<UserBlockingBloc>(),
      ),
      BlocProvider<CryptoBloc>(
        create: (context) => di.sl<CryptoBloc>(),
      ),
      BlocProvider<ImagePickerBloc>(
        create: (context) => di.sl<ImagePickerBloc>(),
      ),
    ];

List<ChangeNotifierProvider> getAppChangeNotifierProviders() => [
      ChangeNotifierProvider(create: (context) => ChatProvider()),
      ChangeNotifierProvider(create: (context) => ProfileProvider()),
      ChangeNotifierProvider(create: (context) => ChatsListProvider()),
    ];
