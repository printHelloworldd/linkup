/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseDatasource {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateUserStatus(bool status) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      DatabaseReference? userRef =
          _firebaseDatabase.ref("users/${user.uid}/online-status");

      // Sets the status "online" = true
      await userRef.set(status);

      // If the user disconnects, automatically sets "offline" = false
      userRef.onDisconnect().set(false);
    }
  }

  Stream<bool> getUserStatus(String userId) {
    return FirebaseDatabase.instance
        .ref("users/$userId/online-status")
        .onValue
        .map((event) => event.snapshot.value as bool);
  }

  Future<void> updateUserTypingStatus(bool status) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      DatabaseReference userRef =
          _firebaseDatabase.ref("users/${user.uid}/isTyping");

      await userRef.set(status);
    }
  }

  Stream<bool> getUserTypingStatus(String userId) {
    return FirebaseDatabase.instance
        .ref("users/$userId/isTyping")
        .onValue
        .map((event) => event.snapshot.value as bool);
  }
}
