import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:desktop_webview_auth/google.dart'; 
import 'package:flutter/foundation.dart';
import 'dart:io';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // GoogleSignIn is a singleton in version 7.x
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  // Auth state changes stream
  Stream<User?> get user => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Email & Password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint("Error in signInWithEmail: $e");
      rethrow;
    }
  }

  // Sign up with Email & Password
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint("Error in signUpWithEmail: $e");
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (!kIsWeb && Platform.isWindows) {
        // Windows specific Google Sign-In using desktop_webview_auth
        final result = await DesktopWebviewAuth.signIn(
          GoogleSignInArgs(
            clientId: '1092735611218-v7v6p5e8v6j4h4e7v6j4h4e7v6j4h4e7.apps.googleusercontent.com', 
            redirectUri: 'https://bootcamp-db92b.firebaseapp.com/__/auth/handler',
          ),
        );

        if (result != null) {
          final credential = GoogleAuthProvider.credential(
            accessToken: result.accessToken,
            idToken: result.idToken,
          );
          return await _auth.signInWithCredential(credential);
        }
      } else {
        // Mobile/Web Google Sign-In
        // In 7.0.0+, authenticate() is the new way to get identity tokens
        // and returns GoogleSignInAccount.
        final GoogleSignInAccount account = await _googleSignIn.authenticate();
        
        // authentication is now a GETTER on GoogleSignInAccount
        final GoogleSignInAuthentication googleAuth = account.authentication;
        
        final credential = GoogleAuthProvider.credential(
          accessToken: null, // accessToken is for authorization, idToken for identity
          idToken: googleAuth.idToken,
        );
        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      debugPrint("Error in signInWithGoogle: $e");
      rethrow;
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
         await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error in signOut: $e");
      rethrow;
    }
  }
}
