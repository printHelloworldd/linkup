/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> insertUser(
      {required Map<String, dynamic> userData, required String userID}) async {
    //! При создании профиля после регистрации нет email и id в userData
    final data = {...userData};

    final CollectionReference mainUserCollection =
        _firestore.collection("Users");

    try {
      final DocumentReference userDoc = mainUserCollection.doc(userID);

      final DocumentReference<Map<String, dynamic>> restrictedUserDoc =
          userDoc.collection("Restricted").doc("data");

      final DocumentReference<Map<String, dynamic>> privateUserDoc =
          userDoc.collection("Private").doc("data");

      DocumentSnapshot doc = await userDoc.get();
      DocumentSnapshot restrictedDoc = await restrictedUserDoc.get();
      DocumentSnapshot privateDoc = await privateUserDoc.get();

      final Map<String, dynamic> restrictedData = data["restrictedUserData"];
      data.remove("restrictedUserData");

      final Map<String, dynamic> privateData = data["privateUserData"];
      data.remove("privateUserData");

      if (doc.exists) {
        userDoc.update(data);
      } else {
        userDoc.set(data);
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
    } catch (e) {
      if (kDebugMode) {
        print("Failed to insert user in Firestore: $e");
      }

      throw Exception(e.toString());
    }
  }

  Future<bool> isUserCreated(String userID) async {
    final doc = await _firestore.collection("Users").doc(userID).get();

    return doc.data()?.isNotEmpty ?? false;
  }

  Future<Map<String, dynamic>?> getUserData(
      String userID, String currentUserID) async {
    final CollectionReference mainUserCollection =
        _firestore.collection("Users");
    Map<String, dynamic> userData = {};

    try {
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
          final Map<String, dynamic> restrictedUserData =
              restrictedDoc.data() as Map<String, dynamic>;
          userData.addAll({"restrictedUserData": restrictedUserData});
        }

        if (privateDoc?.exists ?? false) {
          final Map<String, dynamic> privateUserData =
              privateDoc!.data() as Map<String, dynamic>;
          userData.addAll({"privateUserData": privateUserData});
        }
      }

      return userData;
    } catch (e) {
      if (kDebugMode) {
        print("Failed to get user data from Firestore! $e");
      }

      throw Exception(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers(String currentUserId) async {
    try {
      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection("Users");

      QuerySnapshot querySnapshot =
          await collectionRef.where("uid", isNotEqualTo: currentUserId).get();

      final List<Map<String, dynamic>> allUsersData = [];

      for (final doc in querySnapshot.docs) {
        final String userID = doc.id;

        try {
          final Map<String, dynamic>? fullUserData =
              await getUserData(userID, currentUserId);

          if (fullUserData != null) {
            allUsersData.add(fullUserData);
          }
        } catch (e) {
          if (kDebugMode) {
            print("Failed to get full data for user $userID: $e");
          }
        }
      }

      return allUsersData;
    } catch (e) {
      if (kDebugMode) {
        print("Failed to get docs: $e");
      }

      throw Exception(e.toString());
    }
  }

  Future<void> blockUser(String blockUserID, String currentUserID) async {
    if (blockUserID == currentUserID) return;

    try {
      await _firestore.collection("Users").doc(currentUserID).update({
        "blockedUsers": FieldValue.arrayUnion([blockUserID]),
      });
    } catch (e) {
      if (kDebugMode) {
        print("Failed to block the user with id: $blockUserID. Exception: $e");
      }

      throw Exception(e.toString());
    }
  }

  Future<void> unblockUser(String blockedUserID, String currentUserID) async {
    try {
      await _firestore.collection("Users").doc(currentUserID).update({
        "blockedUsers": FieldValue.arrayRemove([blockedUserID]),
      });
    } catch (e) {
      if (kDebugMode) {
        print(
            "Failed to unblock the user with id: $blockedUserID. Exception: $e");
      }

      throw Exception(e.toString());
    }
  }

  Future<List<String>> getAllBlockedUsers(String currentUserID) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection("Users").doc(currentUserID).get();
      final blockedUsers = documentSnapshot.get("blockedUsers");

      return List<String>.from(blockedUsers);
    } catch (e) {
      if (kDebugMode) {
        print("Failed to get all blocked users: $e");
      }

      throw Exception(e.toString());
    }
  }

  Future<void> saveTokenToDatabase(String userId, String newToken) async {
    DocumentReference userRef = FirebaseFirestore.instance
        .collection("Users")
        .doc(userId)
        .collection("Restricted")
        .doc("data");

    try {
      await userRef.set({"fcmToken": newToken}, SetOptions(merge: true));
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
