import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:metrics/auth/domain/entities/theme_type.dart';
import 'package:metrics/auth/presentation/models/auth_error_message.dart';
import 'package:metrics/auth/presentation/models/user_profile_model.dart';
import 'package:metrics/auth/presentation/state/auth_notifier.dart';

/// Stub implementation on the [AuthNotifier].
///
/// Provides test implementation of the [AuthNotifier] methods and
/// ensures that a user is already logged in into the application.
class SignedInAuthNotifierStub extends ChangeNotifier implements AuthNotifier {
  @override
  String get authErrorMessage => _authExceptionDescription?.message;

  @override
  String get emailErrorMessage => null;

  @override
  String get passwordErrorMessage => null;

  /// Contains text description of any authentication exception that may occur.
  AuthErrorMessage _authExceptionDescription;

  /// Contains a user's authentication status.
  bool _isLoggedIn;

  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  bool get isLoading => false;

  @override
  void subscribeToAuthenticationUpdates() {
    _isLoggedIn = true;
    notifyListeners();
  }

  @override
  Future<void> signInWithEmailAndPassword(
      String email, String password) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  void clearErrorMessages() {}

  @override
  Future<void> signOut() async {
    _isLoggedIn = false;
    notifyListeners();
  }

  @override
  ThemeType get selectedTheme => null;

  @override
  void subscribeToUserProfileUpdates(String id) {}

  @override
  Future<void> updateUserProfile(UserProfileModel userProfile) async {}

  @override
  String get userProfileErrorMessage => null;

  @override
  UserProfileModel get userProfileModel => null;

  @override
  String get userProfileSavingErrorMessage => null;
}
