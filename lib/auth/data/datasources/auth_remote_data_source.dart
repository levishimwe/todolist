import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:savesmart/core/utils/constants.dart';
import 'package:savesmart/features/auth/data/models/user_model.dart';

/// Firebase authentication data source
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<bool> isAuthenticated();

  Future<void> sendPasswordResetEmail(String email);

  Future<UserModel> updateProfile({
    required String uid,
    String? fullName,
    String? phoneNumber,
    String? photoUrl,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      return UserModel.fromFirestore(userDoc);
    } on auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        uid: credential.user!.uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );

      await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toFirestore());

      // Send email verification
      await credential.user!.sendEmailVerification();

      return user;
    } on auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );

      final userDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        final user = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email!,
          fullName: userCredential.user!.displayName ?? 'User',
          photoUrl: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
        );

        await firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(user.toFirestore());

        return user;
      }
    } catch (e) {
      final msg = e.toString();
      // Provide clearer guidance for a common misconfiguration on web
      if (msg.contains('people.googleapis.com') ||
          msg.contains('People API') ||
          msg.contains('PERMISSION_DENIED') && msg.contains('403')) {
        throw Exception(
          'Google Sign-In is not fully configured: People API is disabled for this project.\n'
          'Action: Open Google Cloud Console → APIs & Services → Library → enable "People API" for project, '
          'then wait a minute and try again.',
        );
      }
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([firebaseAuth.signOut(), googleSignIn.signOut()]);
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = firebaseAuth.currentUser;

      if (currentUser == null) {
        return null;
      }

      final userDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        return null;
      }

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return firebaseAuth.currentUser != null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String uid,
    String? fullName,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (fullName != null) updates['fullName'] = fullName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(updates);

      final userDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  String _handleAuthException(auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}
