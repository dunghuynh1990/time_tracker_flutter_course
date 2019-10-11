import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class User {
  User({@required this.uid});

  final String uid;
}

abstract class AuthBase {
  Stream<User> get onAuthStateChanged;

  Future<User> currentUser();

  Future<User> signInAnonymously();

  Future<User> signInWithGoogle();

  Future<User> signInWithFacebook();

  Future<User> signInWithEmailAndPassword(String email, String password);

  Future<User> createUserWithEmailAndPassword(String email, String password);

  Future<void> signOut();
}

class Auth implements AuthBase {
  final FirebaseAuth _fireBaseAuth = FirebaseAuth.instance;

  User _userFromFireBase(FirebaseUser user) {
    if (user == null) {
      return null;
    }
    return User(uid: user.uid);
  }

  Stream<User> get onAuthStateChanged {
    return _fireBaseAuth.onAuthStateChanged.map(_userFromFireBase);
  }

  Future<User> currentUser() async {
    FirebaseUser user = await _fireBaseAuth.currentUser();
    return _userFromFireBase(user);
  }

  Future<User> signInAnonymously() async {
    final authResult = await _fireBaseAuth.signInAnonymously();
    return _userFromFireBase(authResult.user);
  }

  Future<User> signInWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      if (googleAuth.idToken != null && googleAuth.accessToken != null) {
        final authResult = await _fireBaseAuth.signInWithCredential(
          GoogleAuthProvider.getCredential(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken,
          ),
        );
        return _userFromFireBase(authResult.user);
      } else {
        throw StateError('Missing Google Auth Token');
      }
    } else {
      throw StateError('Google sign in aborted');
    }
  }

  Future<User> signInWithFacebook() async {
    final facebookLogin = FacebookLogin();
    FacebookLoginResult result = await facebookLogin.logIn(
      ['public_profile'],
    );
    if (result.accessToken != null) {
      final authResult = await _fireBaseAuth.signInWithCredential(
        FacebookAuthProvider.getCredential(
          accessToken: result.accessToken.token,
        ),
      );
      return _userFromFireBase(authResult.user);
    } else {
      throw StateError('Missing Facebook Access Token');
    }
  }

  Future<User> signInWithEmailAndPassword(String email, String password) async {
    final authResult = await _fireBaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return _userFromFireBase(authResult.user);
  }

  Future<User> createUserWithEmailAndPassword(String email,
      String password) async {
    final authResult = await _fireBaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return _userFromFireBase(authResult.user);
  }

  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    final facebookLogin = FacebookLogin();
    await facebookLogin.logOut();
    return await _fireBaseAuth.signOut();
  }
}
