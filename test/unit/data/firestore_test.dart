import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/data/datasources/remote/firestore_datasource.dart';
import 'package:linkup/core/data/models/user/user_model.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';

import '../../fixtures/user_fixture.dart';

class FirestoreTest {
  final FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
  final DeepCollectionEquality deepEq = const DeepCollectionEquality();

  FirestoreTest() {
    main();
  }

  void main() {
    _insertUserDataInFakeFirestore();
    _insertUserDataInFirestoreEmulator();
  }

  void _insertUserDataInFirestoreEmulator() {
    test("Creates user data in Firestore emulator", () async {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      final FirestoreDatasource datasource = FirestoreDatasource();

      final UserEntity userEntity = UserFixture.create();
      final Map<String, dynamic> userData =
          UserModel.fromEntity(userEntity).toJson(includeSensitiveData: false);

      await datasource.insertUser(userData: userData, userID: userEntity.id);

      final CollectionReference<Map<String, dynamic>> users =
          firestore.collection("Users");
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await users.doc("id").get();
      final Map<String, dynamic>? data = snapshot.data();

      final Map<String, dynamic>? rawUserData =
          await datasource.getUserData("id", "id");

      expect(snapshot.exists, true);
      expect(data, isNotNull);
      expect(data, isNotEmpty);

      if (rawUserData != null) {
        expect(deepEq.hash(rawUserData), equals(deepEq.hash(userData)));
      }
    });
  }

  void _insertUserDataInFakeFirestore() {
    test("Creates user data in fake Firestore located in memory", () async {
      final UserEntity userEntity = UserFixture.create();
      final Map<String, dynamic> userData =
          UserModel.fromEntity(userEntity).toJson(includeSensitiveData: false);

      await _insertInFakeFirestore({...userData});

      final users = fakeFirestore.collection("Users");

      final snapshot = await users.doc("id").get();
      final data = snapshot.data();

      final rawUserData = await _getFromFakeFirestore("id", "id");

      expect(snapshot.exists, true);
      expect(data, isNotNull);
      expect(data, isNotEmpty);
      expect(rawUserData, equals(userData));
    });
  }

  Future<void> _insertInFakeFirestore(Map<String, dynamic> userData) async {
    final String userID = userData["uid"];

    final CollectionReference mainUserCollection =
        fakeFirestore.collection("Users");

    final DocumentReference userDoc = mainUserCollection.doc(userID);

    final DocumentReference<Map<String, dynamic>> restrictedUserDoc =
        userDoc.collection("Restricted").doc("data");

    final DocumentReference<Map<String, dynamic>> privateUserDoc =
        userDoc.collection("Private").doc("data");

    DocumentSnapshot doc = await userDoc.get();
    DocumentSnapshot restrictedDoc = await restrictedUserDoc.get();
    DocumentSnapshot privateDoc = await privateUserDoc.get();

    final Map<String, dynamic> restrictedData = userData["restrictedUserData"];
    userData.remove("restrictedUserData");

    final Map<String, dynamic> privateData = userData["privateUserData"];
    userData.remove("privateUserData");

    if (doc.exists) {
      userDoc.update(userData);
    } else {
      userDoc.set(userData);
    }

    if (restrictedDoc.exists) {
      restrictedUserDoc.update(restrictedData);
    } else {
      restrictedUserDoc.set(restrictedData);
    }

    if (privateDoc.exists) {
      privateUserDoc.update(privateData);
    } else {
      privateUserDoc.set(privateData);
    }
  }

  Future<Map<String, dynamic>?> _getFromFakeFirestore(
      String userID, String currentUserID) async {
    final CollectionReference mainUserCollection =
        fakeFirestore.collection("Users");
    Map<String, dynamic> userData = {};

    final DocumentReference userDoc = mainUserCollection.doc(userID);

    final DocumentReference<Map<String, dynamic>> restrictedUserDoc =
        userDoc.collection("Restricted").doc("data");

    final DocumentReference<Map<String, dynamic>> privateUserDoc =
        userDoc.collection("Private").doc("data");

    DocumentSnapshot doc = await userDoc.get();
    DocumentSnapshot? restrictedDoc = await restrictedUserDoc.get();
    DocumentSnapshot? privateDoc;

    if (currentUserID == userID) {
      privateDoc = await privateUserDoc.get();
    }

    if (doc.exists) {
      userData = doc.data()! as Map<String, dynamic>;

      if (restrictedDoc.exists) {
        final Map<String, dynamic>? restrictedUserData =
            restrictedDoc.data() as Map<String, dynamic>?;
        userData.addAll({"restrictedUserData": restrictedUserData ?? {}});
      }

      if (privateDoc?.exists ?? false) {
        final Map<String, dynamic>? privateUserData =
            privateDoc!.data() as Map<String, dynamic>?;
        userData.addAll({"privateUserData": privateUserData ?? {}});
      }
    }

    return userData;
  }
}
