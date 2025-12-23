import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static FirebaseAuth get _auth {
    if (Firebase.apps.isEmpty) {
      throw StateError('Firebase has not been initialized.');
    }
    return FirebaseAuth.instance;
  }
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    if (Firebase.apps.isEmpty) {
      return;
    }
    await _auth.signOut();
  }

  static User? get currentUser {
    if (Firebase.apps.isEmpty) {
      return null;
    }
    return _auth.currentUser;
  }
}
