/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:firebase_auth/firebase_auth.dart';

/// A data source class that provides Firebase Authentication functionality.
///
/// This class serves as a wrapper around Firebase Auth to provide
/// common authentication operations including user sign-up, sign-in,
/// password reset, email verification, and Google OAuth integration.
///
/// Example usage:
/// ```dart
/// final authDataSource = FirebaseAuthDatasource();
///
/// // Sign up a new user
/// final credential = await authDataSource.signUp(
///   email: 'user@example.com',
///   password: 'securePassword123'
/// );
///
/// // Check if user is authenticated
/// final userId = authDataSource.getCurrentUserID();
/// if (userId != null) {
///   print('User is authenticated: $userId');
/// }
/// ```
class FirebaseAuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // FirebaseAuthDatasource() {
  //   _auth.useAuthEmulator("127.0.0.1", 7077);
  // }

  String? getCurrentUserID() {
    return _auth.currentUser?.uid;
  }

  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  Future<String?> getUserIdToken() async {
    final String? token = await _auth.currentUser?.getIdToken(true);
    return token;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendVerificationEmail() async {
    await _auth.currentUser!.sendEmailVerification();
  }

  bool checkEmailVerification() {
    return _auth.currentUser!.emailVerified;
  }

  Future<void> reloadCurrentUser() async {
    await _auth.currentUser!.reload();
  }

  /// Creates a new user account with email and password.
  ///
  /// [email] The user's email address (will be trimmed of whitespace).
  /// [password] The user's password.
  ///
  /// Returns a [UserCredential] containing information about the newly
  /// created user account.
  ///
  /// Throws a [FirebaseAuthException] if the account creation fails
  /// (e.g., email already in use, weak password).
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final credential = await authDataSource.signUp(
  ///     email: 'newuser@example.com',
  ///     password: 'securePassword123'
  ///   );
  ///   print('User created: ${credential.user?.uid}');
  /// } catch (e) {
  ///   print('Sign up failed: $e');
  /// }
  /// ```
  Future<UserCredential> signUp(
      {required String email, required String password}) async {
    try {
      // _auth.useAuthEmulator("127.0.0.1", 7077);

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: email.trim(), password: password);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Signs in a user with email and password.
  ///
  /// [email] The user's email address (will be trimmed of whitespace).
  /// [password] The user's password.
  ///
  /// Returns a [UserCredential] containing information about the
  /// authenticated user.
  ///
  /// Throws a [FirebaseAuthException] if the sign-in fails
  /// (e.g., invalid email, wrong password, user not found).
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final credential = await authDataSource.signIn(
  ///     email: 'user@example.com',
  ///     password: 'userPassword123'
  ///   );
  ///   print('User signed in: ${credential.user?.uid}');
  /// } catch (e) {
  ///   print('Sign in failed: $e');
  /// }
  /// ```
  Future<UserCredential> signIn(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Signs in a user using Google OAuth (Web implementation).
  ///
  /// This method uses a popup window to handle Google authentication.
  /// The user will be prompted to select their Google account and
  /// grant permission to access their email.
  ///
  /// Returns a [UserCredential] containing information about the
  /// authenticated user.
  ///
  /// Throws a [FirebaseAuthException] if the Google sign-in fails
  /// (e.g., user cancels the popup, network error).
  ///
  /// Note: This implementation is specifically for web platforms.
  /// For mobile platforms, you would need to use the `google_sign_in` package.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final credential = await authDataSource.signInViaGoogle();
  ///   print('Google sign in successful: ${credential.user?.email}');
  /// } catch (e) {
  ///   print('Google sign in failed: $e');
  /// }
  /// ```
  Future<UserCredential> signInViaGoogle() async {
    try {
      // Create Google Auth Provider
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Add scope for email access
      googleProvider.addScope('https://www.googleapis.com/auth/userinfo.email');

      // Set custom parameters to always show account selection
      googleProvider.setCustomParameters({'prompt': 'select_account'});

      // Use popup for web authentication
      return await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Signs out the current user.
  ///
  /// After calling this method, the user will need to sign in again
  /// to access protected resources.
  ///
  /// Example:
  /// ```dart
  /// await authDataSource.signOut();
  /// print('User signed out successfully');
  /// ```
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
