import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:linkup/features/Crypto/data/datasource/web_crypto_datasource.dart';
import 'package:linkup/features/Crypto/data/reposotory/crypto_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/firebase_options.dart';

import 'data/firestore_test.dart';
import 'logic/recommendation_feature_test.dart';
import 'state/filter_user_bloc_test.dart';
import 'state/navigation_bloc_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  FirebaseFirestore.instance.useFirestoreEmulator("localhost", 8080);
  FirebaseAuth.instance.useAuthEmulator("localhost", 7077);

  _testHashing();
  RecommendationFeatureTest();
  FilterUserBlocTest();
  NavigationBlocTest();

  FirestoreTest();
}

void _testHashing() {
  test('Testing method that checks data hashes equality', () async {
    // Setup
    CryptoRepositoryImpl cryptographyRepositoryImpl = CryptoRepositoryImpl(
      cryptoDatasource: WebCryptoDatasource(),
    );

    // Do
    final bool result = await cryptographyRepositoryImpl.isDataEqual("1234",
        "03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4");

    // Test
    expect(result, true);
  });
}
