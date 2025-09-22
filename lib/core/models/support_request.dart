import 'package:cloud_firestore/cloud_firestore.dart';

class SupportRequest {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final String subject;
  final String message;
  final DateTime createdAt;
  final String status;

  const SupportRequest({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.subject,
    required this.message,
    required this.createdAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'subject': subject,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }

  factory SupportRequest.fromMap(Map<String, dynamic> map) {
    return SupportRequest(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userName: map['userName'] ?? '',
      subject: map['subject'] ?? '',
      message: map['message'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
    );
  }
}