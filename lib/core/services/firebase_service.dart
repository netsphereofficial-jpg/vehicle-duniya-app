import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../utils/app_logger.dart';

/// Centralized Firebase service for common operations
class FirebaseService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  FirebaseService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;
  FirebaseStorage get storage => _storage;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get collection reference
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  /// Get document reference
  DocumentReference<Map<String, dynamic>> document(
    String collection,
    String docId,
  ) {
    return _firestore.collection(collection).doc(docId);
  }

  /// Get a document by ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
    String collection,
    String docId,
  ) async {
    AppLogger.firebase('GET', collection, docId: docId);
    return await _firestore.collection(collection).doc(docId).get();
  }

  /// Get all documents in a collection
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(
    String collection, {
    Query<Map<String, dynamic>> Function(CollectionReference<Map<String, dynamic>>)?
        queryBuilder,
  }) async {
    AppLogger.firebase('GET_ALL', collection);
    final ref = _firestore.collection(collection);
    final query = queryBuilder != null ? queryBuilder(ref) : ref;
    return await query.get();
  }

  /// Create a new document
  Future<DocumentReference<Map<String, dynamic>>> createDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    AppLogger.firebase('CREATE', collection);
    return await _firestore.collection(collection).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Set a document with specific ID
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    AppLogger.firebase('SET', collection, docId: docId);
    await _firestore.collection(collection).doc(docId).set(
      {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: merge),
    );
  }

  /// Update a document
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    AppLogger.firebase('UPDATE', collection, docId: docId);
    await _firestore.collection(collection).doc(docId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a document
  Future<void> deleteDocument(String collection, String docId) async {
    AppLogger.firebase('DELETE', collection, docId: docId);
    await _firestore.collection(collection).doc(docId).delete();
  }

  /// Listen to document changes
  Stream<DocumentSnapshot<Map<String, dynamic>>> documentStream(
    String collection,
    String docId,
  ) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  /// Listen to collection changes
  Stream<QuerySnapshot<Map<String, dynamic>>> collectionStream(
    String collection, {
    Query<Map<String, dynamic>> Function(CollectionReference<Map<String, dynamic>>)?
        queryBuilder,
  }) {
    final ref = _firestore.collection(collection);
    final query = queryBuilder != null ? queryBuilder(ref) : ref;
    return query.snapshots();
  }

  /// Upload file to storage
  Future<String> uploadFile(
    String path,
    List<int> data, {
    String? contentType,
  }) async {
    AppLogger.firebase('UPLOAD', path);
    final ref = _storage.ref(path);
    final metadata =
        contentType != null ? SettableMetadata(contentType: contentType) : null;
    await ref.putData(
      data is Uint8List ? data : Uint8List.fromList(data),
      metadata,
    );
    return await ref.getDownloadURL();
  }

  /// Delete file from storage
  Future<void> deleteFile(String path) async {
    AppLogger.firebase('DELETE_FILE', path);
    await _storage.ref(path).delete();
  }

  /// Get file download URL
  Future<String> getDownloadUrl(String path) async {
    return await _storage.ref(path).getDownloadURL();
  }

  /// Parse Firestore timestamp
  static DateTime? parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
