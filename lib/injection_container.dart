/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:get_it/get_it.dart';
import 'package:linkup/injections/auth_feature_injection.dart';
import 'package:linkup/injections/chat_feature_injection.dart';
import 'package:linkup/injections/config_injection.dart';
import 'package:linkup/injections/core_injection.dart';
import 'package:linkup/injections/crypto_feature_injection.dart';
import 'package:linkup/injections/profile_feature_injection.dart';
import 'package:linkup/injections/rec_system_feature_injection.dart';
import 'package:linkup/injections/search_user_feature_injection.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await initConfig();
  await initCore();
  await initCryptoFeature();
  await initAuthFeature();
  await initSearchUserFeature();
  await initChatFeature();
  await initProfileFeature();
  await initRecSystemFeature();
}
