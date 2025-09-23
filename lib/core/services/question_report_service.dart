import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

enum ReportReason {
  incorrectAnswer('Yanlış Cevap'),
  unclearQuestion('Belirsiz Soru'),
  wrongExplanation('Yanlış Açıklama'),
  duplicateQuestion('Tekrar Eden Soru'),
  technicalError('Teknik Hata'),
  other('Diğer');

  const ReportReason(this.displayName);
  final String displayName;
}

class QuestionReport {
  final String id;
  final String questionId;
  final String questionText;
  final String userId;
  final String userEmail;
  final ReportReason reason;
  final String? customReason;
  final String? additionalNotes;
  final DateTime reportedAt;
  final String appVersion;
  final String deviceInfo;

  QuestionReport({
    required this.id,
    required this.questionId,
    required this.questionText,
    required this.userId,
    required this.userEmail,
    required this.reason,
    this.customReason,
    this.additionalNotes,
    required this.reportedAt,
    required this.appVersion,
    required this.deviceInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'questionText': questionText,
      'userId': userId,
      'userEmail': userEmail,
      'reason': reason.name,
      'reasonDisplayName': reason.displayName,
      'customReason': customReason,
      'additionalNotes': additionalNotes,
      'reportedAt': Timestamp.fromDate(reportedAt),
      'appVersion': appVersion,
      'deviceInfo': deviceInfo,
    };
  }

  factory QuestionReport.fromJson(Map<String, dynamic> json) {
    return QuestionReport(
      id: json['id'] ?? '',
      questionId: json['questionId'] ?? '',
      questionText: json['questionText'] ?? '',
      userId: json['userId'] ?? '',
      userEmail: json['userEmail'] ?? '',
      reason: ReportReason.values.firstWhere(
        (e) => e.name == json['reason'],
        orElse: () => ReportReason.other,
      ),
      customReason: json['customReason'],
      additionalNotes: json['additionalNotes'],
      reportedAt: (json['reportedAt'] as Timestamp).toDate(),
      appVersion: json['appVersion'] ?? '',
      deviceInfo: json['deviceInfo'] ?? '',
    );
  }
}

class QuestionReportService {
  final FirebaseFirestore _firestore;
  final FirebaseCrashlytics? _crashlytics;

  QuestionReportService({
    FirebaseFirestore? firestore,
    FirebaseCrashlytics? crashlytics,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _crashlytics = crashlytics;

  Future<void> reportQuestion({
    required String questionId,
    required String questionText,
    required String userId,
    required String userEmail,
    required ReportReason reason,
    String? customReason,
    String? additionalNotes,
    required String appVersion,
    required String deviceInfo,
  }) async {
    try {
      final reportId = '${questionId}_${DateTime.now().millisecondsSinceEpoch}';
      
      final report = QuestionReport(
        id: reportId,
        questionId: questionId,
        questionText: questionText,
        userId: userId,
        userEmail: userEmail,
        reason: reason,
        customReason: customReason,
        additionalNotes: additionalNotes,
        reportedAt: DateTime.now(),
        appVersion: appVersion,
        deviceInfo: deviceInfo,
      );

      print('[QuestionReportService] Attempting to save report to Firebase...');
      print('[QuestionReportService] Report ID: $reportId');
      print('[QuestionReportService] Report data: ${report.toJson()}');
      
      await _firestore
          .collection('question_reports')
          .doc(reportId)
          .set(report.toJson());

      print('[QuestionReportService] Question reported successfully: $questionId');
    } catch (e) {
      print('[QuestionReportService] ERROR: Failed to report question: $e');
      print('[QuestionReportService] Error type: ${e.runtimeType}');
      print('[QuestionReportService] Error details: ${e.toString()}');
      
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Failed to report question: $questionId'],
      );
      rethrow;
    }
  }


  Future<List<QuestionReport>> getReportsForQuestion(String questionId) async {
    try {
      final querySnapshot = await _firestore
          .collection('question_reports')
          .where('questionId', isEqualTo: questionId)
          .orderBy('reportedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => QuestionReport.fromJson(doc.data()))
          .toList();
    } catch (e) {
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Failed to get reports for question: $questionId'],
      );
      return [];
    }
  }

  Future<int> getReportCountForQuestion(String questionId) async {
    try {
      final querySnapshot = await _firestore
          .collection('question_reports')
          .where('questionId', isEqualTo: questionId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      await _crashlytics?.recordError(
        e,
        null,
        fatal: false,
        information: ['Failed to get report count for question: $questionId'],
      );
      return 0;
    }
  }
}
