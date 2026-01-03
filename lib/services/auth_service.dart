import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  static const _pendingEmailKey = 'dutyspin.pending_email_link_email.v1';

  Future<void> storePendingEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingEmailKey, email.trim().toLowerCase());
  }

  Future<String?> loadPendingEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_pendingEmailKey);
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }

  Future<void> clearPendingEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingEmailKey);
  }

  Future<void> sendEmailSignInLink({required String email}) async {
    final e = email.trim().toLowerCase();
    if (!e.contains('@')) throw ArgumentError('Enter a valid email');

    // This URL must be added under Firebase Console -> Authentication -> Settings -> Authorized domains.
    // For mobile deep-linking you normally configure an app link / dynamic link domain.
    // DutySpin supports a "paste link" flow so deep-linking is optional.
    final actionCodeSettings = ActionCodeSettings(
      url: 'https://dutyspin.app/login',
      handleCodeInApp: true,
      androidPackageName: 'com.example.choreflow_flutter',
      androidInstallApp: false,
      androidMinimumVersion: '1',
      iOSBundleId: 'com.example.choreflowFlutter',
    );

    await _auth.sendSignInLinkToEmail(email: e, actionCodeSettings: actionCodeSettings);
    await storePendingEmail(e);
  }

  bool isSignInWithEmailLink(String link) {
    return _auth.isSignInWithEmailLink(link);
  }

  Future<UserCredential> signInWithEmailLink({required String email, required String emailLink}) async {
    final e = email.trim().toLowerCase();
    if (e.isEmpty) throw ArgumentError('Email is required');
    if (emailLink.trim().isEmpty) throw ArgumentError('Link is required');

    final cred = await _auth.signInWithEmailLink(email: e, emailLink: emailLink.trim());
    await clearPendingEmail();
    return cred;
  }

  Future<void> ensureSignedInAnonymouslyIfNeeded() async {
    if (_auth.currentUser != null) return;
    await _auth.signInAnonymously();
  }
}
