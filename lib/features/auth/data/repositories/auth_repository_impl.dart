import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/data/models/user_model.dart';
import '../../../../shared/domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _firebaseStorage;
  final StorageService _storageService;

  String? _verificationId;
  int? _resendToken;

  AuthRepositoryImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required StorageService storageService,
    FirebaseStorage? firebaseStorage,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _storageService = storageService,
        _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  @override
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      try {
        final doc = await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(firebaseUser.uid)
            .get();
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
        return null;
      } catch (e) {
        AppLogger.error('AuthRepository', 'Error getting user', error: e);
        return null;
      }
    });
  }

  @override
  Future<Either<Failure, String>> sendOtp(String phoneNumber) async {
    try {
      AppLogger.info('AuthRepository', 'Sending OTP to $phoneNumber');

      final completer = Completer<Either<Failure, String>>();

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted:
            (firebase_auth.PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          AppLogger.info('AuthRepository', 'Auto-verification completed');
        },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          AppLogger.error('AuthRepository', 'Verification failed', error: e);
          if (!completer.isCompleted) {
            if (e.code == 'invalid-phone-number') {
              completer.complete(left(AuthFailure.invalidPhone()));
            } else if (e.code == 'too-many-requests') {
              completer.complete(left(AuthFailure.tooManyRequests()));
            } else {
              completer.complete(left(AuthFailure(message: e.message ?? 'Verification failed')));
            }
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          AppLogger.info('AuthRepository', 'Code sent, verificationId: $verificationId');
          _verificationId = verificationId;
          _resendToken = resendToken;
          if (!completer.isCompleted) {
            completer.complete(right(verificationId));
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          AppLogger.info('AuthRepository', 'Auto retrieval timeout');
          _verificationId = verificationId;
        },
      );

      return await completer.future;
    } catch (e) {
      AppLogger.error('AuthRepository', 'Send OTP error', error: e);
      return left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      AppLogger.info('AuthRepository', 'Verifying OTP');

      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return left(const AuthFailure(message: 'Sign in failed'));
      }

      // Check if user exists in Firestore
      final userDoc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();

      User user;
      if (userDoc.exists) {
        // Existing user
        user = UserModel.fromFirestore(userDoc);
        AppLogger.info('AuthRepository', 'Existing user logged in');
      } else {
        // New user - create profile
        final newUser = UserModel(
          id: firebaseUser.uid,
          name: '',
          phone: firebaseUser.phoneNumber?.replaceAll('+91', '') ?? '',
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(firebaseUser.uid)
            .set(newUser.toFirestore());

        user = newUser;
        AppLogger.info('AuthRepository', 'New user created');
      }

      // Save to local storage
      await _storageService.setUserId(user.id);
      await _storageService.setUserPhone(user.phone);
      await _storageService.setUserName(user.name);

      return right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.error('AuthRepository', 'Verify OTP error', error: e);
      if (e.code == 'invalid-verification-code') {
        return left(AuthFailure.invalidOtp());
      } else if (e.code == 'session-expired') {
        return left(AuthFailure.otpExpired());
      }
      return left(AuthFailure(message: e.message ?? 'Verification failed'));
    } catch (e) {
      AppLogger.error('AuthRepository', 'Verify OTP error', error: e);
      return left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return right(null);
      }

      final userDoc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        return right(null);
      }

      return right(UserModel.fromFirestore(userDoc));
    } catch (e) {
      AppLogger.error('AuthRepository', 'Get current user error', error: e);
      return left(const FirebaseFailure());
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(User user) async {
    try {
      AppLogger.info('AuthRepository', 'Updating profile');

      final userModel = UserModel.fromEntity(user);
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.id)
          .update(userModel.toUpdateMap());

      // Update local storage
      await _storageService.setUserName(user.name);

      return right(user);
    } catch (e) {
      AppLogger.error('AuthRepository', 'Update profile error', error: e);
      return left(const FirebaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      AppLogger.info('AuthRepository', 'Signing out');
      await _firebaseAuth.signOut();
      await _storageService.clearUserData();
      _verificationId = null;
      _resendToken = null;
      return right(null);
    } catch (e) {
      AppLogger.error('AuthRepository', 'Sign out error', error: e);
      return left(const AuthFailure(message: 'Sign out failed'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(Uint8List imageData) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return left(const AuthFailure(message: 'User not authenticated'));
      }

      AppLogger.info('AuthRepository', 'Uploading profile image');

      final ref = _firebaseStorage.ref('profile_images/$userId.jpg');
      final metadata = SettableMetadata(contentType: 'image/jpeg');

      await ref.putData(imageData, metadata);
      final downloadUrl = await ref.getDownloadURL();

      AppLogger.info('AuthRepository', 'Profile image uploaded: $downloadUrl');
      return right(downloadUrl);
    } catch (e) {
      AppLogger.error('AuthRepository', 'Upload profile image error', error: e);
      return left(const FirebaseFailure(message: 'Failed to upload image'));
    }
  }
}
