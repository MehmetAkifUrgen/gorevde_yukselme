import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/support_request.dart';

class SupportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'support_requests';

  Future<void> createSupportRequest(SupportRequest request) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(request.id)
          .set(request.toMap());
    } catch (e) {
      throw Exception('Destek talebi gönderilirken hata oluştu: $e');
    }
  }

  Future<List<SupportRequest>> getUserSupportRequests(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SupportRequest.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Destek talepleri alınırken hata oluştu: $e');
    }
  }

  String generateRequestId() {
    return _firestore.collection(_collection).doc().id;
  }
}