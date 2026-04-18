// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --------------------------
  // SIGN UP (STUDENT)
  // --------------------------
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String role, // "student"
  }) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCred.user!.uid;

      await _db.collection("users").doc(uid).set({
        "uid": uid,
        "name": name,
        "email": email,
        "role": role,
        "createdAt": FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // --------------------------
  // SIGN IN
  // --------------------------
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // --------------------------
  // GET USER ROLE
  // --------------------------
  Future<String?> getCurrentUserRole() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final snap = await _db.collection("users").doc(uid).get();
      if (!snap.exists) return null;

      return snap.data()?["role"];
    } catch (_) {
      return null;
    }
  }

  // ------------------------------------------------
  // STREAM → LISTENS TO LOGIN + ROLE CHANGES
  // (Used in main.dart for secure navigation)
  // ------------------------------------------------
  Stream<Map<String, dynamic>?> userWithRoleStream() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;

      final doc = await _db.collection("users").doc(user.uid).get();
      if (!doc.exists) return null;

      return {
        "uid": user.uid,
        "role": doc.data()!["role"],
      };
    });
  }

  // --------------------------
  // SIGN OUT
  // --------------------------
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
