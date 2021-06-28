import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:dvx_flutter_firebase/src/firebase/auth.dart';

class FirebaseUserProvider extends ChangeNotifier {
  FirebaseUserProvider() {
    _setup();
  }

  auth.User? _user;
  final AuthService _auth = AuthService();
  bool _initalized = false;
  bool _isAdmin = false;

  bool get isAdmin => _isAdmin;
  bool get hasUser => _user != null;
  String get userId => hasUser ? _user!.uid : '';

  bool get initalized => _initalized;

  // work around for reload
  Future<void> reload() async {
    await _user!.reload();
    _user = _auth.currentUser;

    notifyListeners();
  }

  String get identity {
    return _auth.identity;
  }

  String get displayName {
    return _auth.displayName;
  }

  String get phoneNumber {
    return _auth.phoneNumber;
  }

  String get email {
    return _auth.email;
  }

  String get photoUrl {
    return _auth.photoUrl;
  }

  Future<void> updateProfile(String displayName, String? photoURL) async {
    await _user!.updatePhotoURL(photoURL);
    await _user!.updateDisplayName(displayName);
    await reload();
  }

  Future<void> updateEmail(String email) async {
    await _user!.updateEmail(email);
    await reload();
  }

  Future<void> _setup() async {
    final Stream<auth.User?> stream = _auth.userStream;

    await stream.forEach((auth.User? user) async {
      _user = user;

      // this checks for user == null
      _isAdmin = await _auth.isAdmin();

      // want to avoid flashing the login screen until we get the
      // first response
      _initalized = true;

      notifyListeners();
    });
  }
}
