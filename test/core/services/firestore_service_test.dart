import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:gorevde_yukselme/core/services/firestore_service.dart';

import 'firestore_service_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  Query,
  WriteBatch,
  FirebaseCrashlytics,
])
void main() {
  group('FirestoreService Tests', () {
    late FirestoreService firestoreService;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockCollectionRef;
    late MockDocumentReference<Map<String, dynamic>> mockDocumentRef;
    late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;
    late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
    late MockQuery<Map<String, dynamic>> mockQuery;
    late MockWriteBatch mockWriteBatch;
    late MockFirebaseCrashlytics mockFirebaseCrashlytics;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollectionRef = MockCollectionReference<Map<String, dynamic>>();
      mockDocumentRef = MockDocumentReference<Map<String, dynamic>>();
      mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      mockQuery = MockQuery<Map<String, dynamic>>();
      mockWriteBatch = MockWriteBatch();
      mockFirebaseCrashlytics = MockFirebaseCrashlytics();

      // Create FirestoreService with mocked dependencies
      firestoreService = FirestoreService.test(
        firestore: mockFirestore,
        crashlytics: mockFirebaseCrashlytics,
      );

      // Setup common mock behaviors
      when(mockFirestore.collection(any)).thenReturn(mockCollectionRef);
      when(mockCollectionRef.doc(any)).thenReturn(mockDocumentRef);
    });

    group('createDocument', () {
      test('should create document successfully', () async {
        // Arrange
        const String collection = 'test_collection';
        const String documentId = 'test_doc';
        const Map<String, dynamic> data = {'name': 'test', 'value': 123};

        when(mockDocumentRef.set(any, any)).thenAnswer((_) async {});

        // Act
        await firestoreService.createDocument(
          collection: collection,
          documentId: documentId,
          data: data,
        );

        // Assert
        verify(mockFirestore.collection(collection)).called(1);
        verify(mockCollectionRef.doc(documentId)).called(1);
        verify(mockDocumentRef.set(data, any)).called(1);
      });

      test('should handle error and record to crashlytics', () async {
        // Arrange
        const String collection = 'test_collection';
        const String documentId = 'test_doc';
        const Map<String, dynamic> data = {'name': 'test'};
        final exception = Exception('Firestore error');

        when(mockDocumentRef.set(any, any)).thenThrow(exception);

        // Act & Assert
        expect(
          () => firestoreService.createDocument(
            collection: collection,
            documentId: documentId,
            data: data,
          ),
          throwsA(equals(exception)),
        );

        verify(mockFirebaseCrashlytics.recordError(
          exception,
          null,
          fatal: false,
          information: ['Failed to create document in $collection'],
        )).called(1);
      });
    });

    group('updateDocument', () {
      test('should update document successfully', () async {
        // Arrange
        const String collection = 'test_collection';
        const String documentId = 'test_doc';
        const Map<String, dynamic> data = {'name': 'updated'};

        when(mockDocumentRef.update(any)).thenAnswer((_) async {});

        // Act
        await firestoreService.updateDocument(
          collection: collection,
          documentId: documentId,
          data: data,
        );

        // Assert
        verify(mockFirestore.collection(collection)).called(1);
        verify(mockCollectionRef.doc(documentId)).called(1);
        verify(mockDocumentRef.update(data)).called(1);
      });

      test('should handle error and record to crashlytics', () async {
        // Arrange
        const String collection = 'test_collection';
        const String documentId = 'test_doc';
        const Map<String, dynamic> data = {'name': 'updated'};
        final exception = Exception('Update failed');

        when(mockDocumentRef.update(any)).thenThrow(exception);

        // Act & Assert
        expect(
          () => firestoreService.updateDocument(
            collection: collection,
            documentId: documentId,
            data: data,
          ),
          throwsA(equals(exception)),
        );

        verify(mockFirebaseCrashlytics.recordError(
          exception,
          null,
          fatal: false,
          information: ['Failed to update document in $collection'],
        )).called(1);
      });
    });

    group('getDocument', () {
      test('should get document successfully', () async {
        // Arrange
        const String collection = 'test_collection';
        const String documentId = 'test_doc';

        when(mockDocumentRef.get()).thenAnswer((_) async => mockDocumentSnapshot);

        // Act
        final result = await firestoreService.getDocument(
          collection: collection,
          documentId: documentId,
        );

        // Assert
        expect(result, equals(mockDocumentSnapshot));
        verify(mockFirestore.collection(collection)).called(1);
        verify(mockCollectionRef.doc(documentId)).called(1);
        verify(mockDocumentRef.get()).called(1);
      });

      test('should handle error and record to crashlytics', () async {
        // Arrange
        const String collection = 'test_collection';
        const String documentId = 'test_doc';
        final exception = Exception('Get failed');

        when(mockDocumentRef.get()).thenThrow(exception);

        // Act & Assert
        expect(
          () => firestoreService.getDocument(
            collection: collection,
            documentId: documentId,
          ),
          throwsA(equals(exception)),
        );

        verify(mockFirebaseCrashlytics.recordError(
          exception,
          null,
          fatal: false,
          information: ['Failed to get document from $collection'],
        )).called(1);
      });
    });

    group('deleteDocument', () {
      test('should delete document successfully', () async {
        // Arrange
        const String collection = 'test_collection';
        const String documentId = 'test_doc';

        when(mockDocumentRef.delete()).thenAnswer((_) async {});

        // Act
        await firestoreService.deleteDocument(
          collection: collection,
          documentId: documentId,
        );

        // Assert
        verify(mockFirestore.collection(collection)).called(1);
        verify(mockCollectionRef.doc(documentId)).called(1);
        verify(mockDocumentRef.delete()).called(1);
      });

      test('should handle error and record to crashlytics', () async {
        // Arrange
        const String collection = 'test_collection';
        const String documentId = 'test_doc';
        final exception = Exception('Delete failed');

        when(mockDocumentRef.delete()).thenThrow(exception);

        // Act & Assert
        expect(
          () => firestoreService.deleteDocument(
            collection: collection,
            documentId: documentId,
          ),
          throwsA(equals(exception)),
        );

        verify(mockFirebaseCrashlytics.recordError(
          exception,
          null,
          fatal: false,
          information: ['Failed to delete document from $collection'],
        )).called(1);
      });
    });

    group('getCollectionStream', () {
      test('should get collection stream without query', () {
        // Arrange
        const String collection = 'test_collection';
        final stream = Stream<QuerySnapshot<Map<String, dynamic>>>.empty();

        when(mockCollectionRef.snapshots()).thenAnswer((_) => stream);

        // Act
        final result = firestoreService.getCollectionStream(collection: collection);

        // Assert
        expect(result, equals(stream));
        verify(mockFirestore.collection(collection)).called(1);
        verify(mockCollectionRef.snapshots()).called(1);
      });

      test('should get collection stream with query', () {
        // Arrange
        const String collection = 'test_collection';
        final stream = Stream<QuerySnapshot<Map<String, dynamic>>>.empty();

        when(mockQuery.snapshots()).thenAnswer((_) => stream);

        // Act
        final result = firestoreService.getCollectionStream(
          collection: collection,
          query: mockQuery,
        );

        // Assert
        expect(result, equals(stream));
        verify(mockQuery.snapshots()).called(1);
        verifyNever(mockFirestore.collection(collection));
      });
    });

    group('getDocumentStream', () {
      test('should get document stream successfully', () {
        // Arrange
        const String collection = 'test_collection';
        const String documentId = 'test_doc';
        final stream = Stream<DocumentSnapshot<Map<String, dynamic>>>.empty();

        when(mockDocumentRef.snapshots()).thenAnswer((_) => stream);

        // Act
        final result = firestoreService.getDocumentStream(
          collection: collection,
          documentId: documentId,
        );

        // Assert
        expect(result, equals(stream));
        verify(mockFirestore.collection(collection)).called(1);
        verify(mockCollectionRef.doc(documentId)).called(1);
        verify(mockDocumentRef.snapshots()).called(1);
      });
    });

    group('performBatch', () {
      test('should perform batch operations successfully', () async {
        // Arrange
        final operations = [
          {
            'type': 'set',
            'collection': 'test_collection',
            'documentId': 'doc1',
            'data': {'name': 'test1'},
          },
          {
            'type': 'update',
            'collection': 'test_collection',
            'documentId': 'doc2',
            'data': {'name': 'test2'},
          },
          {
            'type': 'delete',
            'collection': 'test_collection',
            'documentId': 'doc3',
            'data': null,
          },
        ];

        when(mockFirestore.batch()).thenReturn(mockWriteBatch);
        when(mockWriteBatch.set(any, any)).thenReturn(mockWriteBatch);
        when(mockWriteBatch.update(any, any)).thenReturn(mockWriteBatch);
        when(mockWriteBatch.delete(any)).thenReturn(mockWriteBatch);
        when(mockWriteBatch.commit()).thenAnswer((_) async {});

        // Act
        await firestoreService.performBatch(operations);

        // Assert
        verify(mockFirestore.batch()).called(1);
        verify(mockWriteBatch.set(any, {'name': 'test1'})).called(1);
        verify(mockWriteBatch.update(any, {'name': 'test2'})).called(1);
        verify(mockWriteBatch.delete(any)).called(1);
        verify(mockWriteBatch.commit()).called(1);
      });

      test('should handle batch error and record to crashlytics', () async {
        // Arrange
        final operations = [
          {
            'type': 'set',
            'collection': 'test_collection',
            'documentId': 'doc1',
            'data': {'name': 'test1'},
          },
        ];
        final exception = Exception('Batch failed');

        when(mockFirestore.batch()).thenReturn(mockWriteBatch);
        when(mockWriteBatch.set(any, any)).thenReturn(mockWriteBatch);
        when(mockWriteBatch.commit()).thenThrow(exception);

        // Act & Assert
        expect(
          () => firestoreService.performBatch(operations),
          throwsA(equals(exception)),
        );

        verify(mockFirebaseCrashlytics.recordError(
          exception,
          null,
          fatal: false,
          information: ['Failed to perform batch operations'],
        )).called(1);
      });
    });

    group('User Profile Methods', () {
      test('should create user profile successfully', () async {
        // Arrange
        const String userId = 'user123';
        const Map<String, dynamic> userData = {'name': 'John Doe', 'email': 'john@example.com'};

        when(mockDocumentRef.set(any, any)).thenAnswer((_) async {});

        // Act
        await firestoreService.createUserProfile(
          userId: userId,
          userData: userData,
        );

        // Assert
        verify(mockFirestore.collection('users')).called(1);
        verify(mockCollectionRef.doc(userId)).called(1);
        verify(mockDocumentRef.set(any, any)).called(1);
      });

      test('should update user profile successfully', () async {
        // Arrange
        const String userId = 'user123';
        const Map<String, dynamic> userData = {'name': 'Jane Doe'};

        when(mockDocumentRef.update(any)).thenAnswer((_) async {});

        // Act
        await firestoreService.updateUserProfile(
          userId: userId,
          userData: userData,
        );

        // Assert
        verify(mockFirestore.collection('users')).called(1);
        verify(mockCollectionRef.doc(userId)).called(1);
        verify(mockDocumentRef.update(any)).called(1);
      });

      test('should get user profile successfully', () async {
        // Arrange
        const String userId = 'user123';

        when(mockDocumentRef.get()).thenAnswer((_) async => mockDocumentSnapshot);

        // Act
        final result = await firestoreService.getUserProfile(userId: userId);

        // Assert
        expect(result, equals(mockDocumentSnapshot));
        verify(mockFirestore.collection('users')).called(1);
        verify(mockCollectionRef.doc(userId)).called(1);
        verify(mockDocumentRef.get()).called(1);
      });

      test('should get user profile stream successfully', () {
        // Arrange
        const String userId = 'user123';
        final stream = Stream<DocumentSnapshot<Map<String, dynamic>>>.empty();

        when(mockDocumentRef.snapshots()).thenAnswer((_) => stream);

        // Act
        final result = firestoreService.getUserProfileStream(userId: userId);

        // Assert
        expect(result, equals(stream));
        verify(mockFirestore.collection('users')).called(1);
        verify(mockCollectionRef.doc(userId)).called(1);
        verify(mockDocumentRef.snapshots()).called(1);
      });
    });

    group('User Answer Methods', () {
      test('should save user answer successfully', () async {
        // Arrange
        const String userId = 'user123';
        const String questionId = 'q456';
        const Map<String, dynamic> answerData = {'answer': 'A', 'correct': true};

        when(mockDocumentRef.set(any, any)).thenAnswer((_) async {});

        // Act
        await firestoreService.saveUserAnswer(
          userId: userId,
          questionId: questionId,
          answerData: answerData,
        );

        // Assert
        verify(mockFirestore.collection('user_answers')).called(1);
        verify(mockCollectionRef.doc('${userId}_$questionId')).called(1);
        verify(mockDocumentRef.set(any, any)).called(1);
      });

      test('should get user answers stream successfully', () {
        // Arrange
        const String userId = 'user123';
        final stream = Stream<QuerySnapshot<Map<String, dynamic>>>.empty();

        when(mockCollectionRef.where(any, isEqualTo: anyNamed('isEqualTo')))
            .thenReturn(mockQuery);
        when(mockQuery.orderBy(any, descending: anyNamed('descending')))
            .thenReturn(mockQuery);
        when(mockQuery.snapshots()).thenAnswer((_) => stream);

        // Act
        final result = firestoreService.getUserAnswersStream(userId: userId);

        // Assert
        expect(result, equals(stream));
        verify(mockFirestore.collection('user_answers')).called(1);
        verify(mockCollectionRef.where('userId', isEqualTo: userId)).called(1);
        verify(mockQuery.orderBy('answeredAt', descending: true)).called(1);
      });
    });

    group('Performance Data Methods', () {
      test('should save performance data successfully', () async {
        // Arrange
        const String userId = 'user123';
        const Map<String, dynamic> performanceData = {'score': 85, 'timeSpent': 120};

        when(mockDocumentRef.set(any, any)).thenAnswer((_) async {});

        // Act
        await firestoreService.savePerformanceData(
          userId: userId,
          performanceData: performanceData,
        );

        // Assert
        verify(mockFirestore.collection('user_performance')).called(1);
        verify(mockCollectionRef.doc(any)).called(1);
        verify(mockDocumentRef.set(any, any)).called(1);
      });
    });
  });
}