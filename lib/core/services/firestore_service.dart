import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseCrashlytics? _crashlytics;

  // Default constructor for production use
  FirestoreService()
      : _firestore = FirebaseFirestore.instance,
        _crashlytics = FirebaseCrashlytics.instance;

  // Constructor for testing with dependency injection
  FirestoreService.test({
    required FirebaseFirestore firestore,
    FirebaseCrashlytics? crashlytics,
  }) : _firestore = firestore,
       _crashlytics = crashlytics;

  // Generic method to create a document
  Future<void> createDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore
          .collection(collection)
          .doc(documentId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Failed to create document in $collection'],
      );
      rethrow;
    }
  }

  // Generic method to update a document
  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore
          .collection(collection)
          .doc(documentId)
          .update(data);
    } catch (e) {
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Failed to update document in $collection'],
      );
      rethrow;
    }
  }

  // Generic method to get a document
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      return await _firestore
          .collection(collection)
          .doc(documentId)
          .get();
    } catch (e) {
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Failed to get document from $collection'],
      );
      rethrow;
    }
  }

  // Generic method to delete a document
  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _firestore
          .collection(collection)
          .doc(documentId)
          .delete();
    } catch (e) {
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Failed to delete document from $collection'],
      );
      rethrow;
    }
  }

  // Generic method to get a collection stream
  Stream<QuerySnapshot<Map<String, dynamic>>> getCollectionStream({
    required String collection,
    Query<Map<String, dynamic>>? query,
  }) {
    try {
      if (query != null) {
        return query.snapshots();
      }
      return _firestore.collection(collection).snapshots();
    } catch (e) {
      _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Failed to get collection stream from $collection'],
      );
      rethrow;
    }
  }

  // Generic method to get a document stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> getDocumentStream({
    required String collection,
    required String documentId,
  }) {
    try {
      return _firestore
          .collection(collection)
          .doc(documentId)
          .snapshots();
    } catch (e) {
      _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Failed to get document stream from $collection'],
      );
      rethrow;
    }
  }

  // Method to perform batch operations
  Future<void> performBatch(
    List<Map<String, dynamic>> operations,
  ) async {
    try {
      final batch = _firestore.batch();
      
      for (final operation in operations) {
        final type = operation['type'] as String;
        final collection = operation['collection'] as String;
        final documentId = operation['documentId'] as String;
        final data = operation['data'] as Map<String, dynamic>?;
        
        final docRef = _firestore.collection(collection).doc(documentId);
        
        switch (type) {
          case 'set':
            batch.set(docRef, data!);
            break;
          case 'update':
            batch.update(docRef, data!);
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      }
      
      await batch.commit();
    } catch (e) {
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Failed to perform batch operations'],
      );
      rethrow;
    }
  }

  // User-specific methods
  Future<void> createUserProfile({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    await createDocument(
      collection: 'users',
      documentId: userId,
      data: {
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    await updateDocument(
      collection: 'users',
      documentId: userId,
      data: {
        ...userData,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile({
    required String userId,
  }) async {
    return await getDocument(
      collection: 'users',
      documentId: userId,
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfileStream({
    required String userId,
  }) {
    return getDocumentStream(
      collection: 'users',
      documentId: userId,
    );
  }

  // Question-specific methods
  Future<void> saveUserAnswer({
    required String userId,
    required String questionId,
    required Map<String, dynamic> answerData,
  }) async {
    await createDocument(
      collection: 'user_answers',
      documentId: '${userId}_$questionId',
      data: {
        'userId': userId,
        'questionId': questionId,
        ...answerData,
        'answeredAt': FieldValue.serverTimestamp(),
      },
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserAnswersStream({
    required String userId,
  }) {
    final query = _firestore
        .collection('user_answers')
        .where('userId', isEqualTo: userId)
        .orderBy('answeredAt', descending: true);
    
    return getCollectionStream(
      collection: 'user_answers',
      query: query,
    );
  }

  // Performance tracking methods
  Future<void> savePerformanceData({
    required String userId,
    required Map<String, dynamic> performanceData,
  }) async {
    await createDocument(
      collection: 'user_performance',
      documentId: '${userId}_${DateTime.now().millisecondsSinceEpoch}',
      data: {
        'userId': userId,
        ...performanceData,
        'recordedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  // Delete all user data from Firestore
  Future<void> deleteAllUserData({required String userId}) async {
    try {
      final batch = _firestore.batch();

      // Delete user profile
      batch.delete(_firestore.collection('users').doc(userId));

      // Delete user answers
      final answersQuery = await _firestore
          .collection('user_answers')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (final doc in answersQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user support requests
      final supportQuery = await _firestore
          .collection('support_requests')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (final doc in supportQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user performance data
      final performanceQuery = await _firestore
          .collection('user_performance')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (final doc in performanceQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user subscription data
      batch.delete(_firestore.collection('subscriptions').doc(userId));

      // Delete user performance summary (if exists)
      batch.delete(_firestore.collection('performance').doc(userId));

      // Commit all deletions
      await batch.commit();
    } catch (e) {
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Failed to delete all user data for userId: $userId'],
      );
      rethrow;
    }
  }
}