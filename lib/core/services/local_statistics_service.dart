import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_service.dart';

class LocalStatisticsService {
  final SharedPreferences _prefs;

  LocalStatisticsService(this._prefs);

  String _key(String userId) => 'stats_${userId.isEmpty ? 'guest' : userId}';

  Map<String, dynamic> _empty() => {
        'totalQuestions': 0,
        'correct': 0,
        'incorrect': 0,
        'studyTimeMinutes': 0,
        'totalTests': 0,
        'totalRandomQuestions': 0,
        'subjectStats': <String, Map<String, dynamic>>{},
        'professionStats': <String, Map<String, dynamic>>{},
        'ministryStats': <String, Map<String, dynamic>>{},
      };

  Future<Map<String, dynamic>> getStats(String userId) async {
    final key = _key(userId);
    print('[LocalStatisticsService] getStats called - UserId: $userId, Key: $key');
    final raw = _prefs.getString(key);
    print('[LocalStatisticsService] Raw data: $raw');
    if (raw == null || raw.isEmpty) {
      print('[LocalStatisticsService] No data found, returning empty stats');
      return _empty();
    }
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      final result = {
        ..._empty(),
        ...map,
      };
      print('[LocalStatisticsService] Parsed stats: $result');
      return result;
    } catch (e) {
      print('[LocalStatisticsService] Error parsing stats: $e');
      return _empty();
    }
  }

  Future<void> _setStats(String userId, Map<String, dynamic> stats) async {
    await _prefs.setString(_key(userId), json.encode(stats));
  }

  Future<void> incrementQuestion({
    required String userId, 
    required bool isCorrect,
    String? subject,
    String? profession,
    String? ministry,
    bool isRandomQuestion = false,
  }) async {
    print('[LocalStatisticsService] incrementQuestion called - UserId: $userId, IsCorrect: $isCorrect');
    print('[LocalStatisticsService] Subject: $subject, Profession: $profession, Ministry: $ministry');
    print('[LocalStatisticsService] IsRandomQuestion: $isRandomQuestion');
    
    final stats = await getStats(userId);
    print('[LocalStatisticsService] Current stats: $stats');
    
    // Genel istatistikler
    stats['totalQuestions'] = (stats['totalQuestions'] as int) + 1;
    if (isCorrect) {
      stats['correct'] = (stats['correct'] as int) + 1;
    } else {
      stats['incorrect'] = (stats['incorrect'] as int) + 1;
    }
    
    // Random questions sayısı
    if (isRandomQuestion) {
      stats['totalRandomQuestions'] = (stats['totalRandomQuestions'] as int) + 1;
    }
    
    
    // Konu istatistikleri
    if (subject != null) {
      final subjectStats = Map<String, dynamic>.from(stats['subjectStats'] ?? {});
      if (!subjectStats.containsKey(subject)) {
        subjectStats[subject] = {'total': 0, 'correct': 0, 'incorrect': 0};
      }
      subjectStats[subject]['total'] = (subjectStats[subject]['total'] as int) + 1;
      if (isCorrect) {
        subjectStats[subject]['correct'] = (subjectStats[subject]['correct'] as int) + 1;
      } else {
        subjectStats[subject]['incorrect'] = (subjectStats[subject]['incorrect'] as int) + 1;
      }
      stats['subjectStats'] = subjectStats;
    }
    
    // Meslek istatistikleri
    if (profession != null) {
      final professionStats = Map<String, dynamic>.from(stats['professionStats'] ?? {});
      if (!professionStats.containsKey(profession)) {
        professionStats[profession] = {'total': 0, 'correct': 0, 'incorrect': 0};
      }
      professionStats[profession]['total'] = (professionStats[profession]['total'] as int) + 1;
      if (isCorrect) {
        professionStats[profession]['correct'] = (professionStats[profession]['correct'] as int) + 1;
      } else {
        professionStats[profession]['incorrect'] = (professionStats[profession]['incorrect'] as int) + 1;
      }
      stats['professionStats'] = professionStats;
    }
    
    // Bakanlık istatistikleri
    if (ministry != null) {
      final ministryStats = Map<String, dynamic>.from(stats['ministryStats'] ?? {});
      if (!ministryStats.containsKey(ministry)) {
        ministryStats[ministry] = {'total': 0, 'correct': 0, 'incorrect': 0};
      }
      ministryStats[ministry]['total'] = (ministryStats[ministry]['total'] as int) + 1;
      if (isCorrect) {
        ministryStats[ministry]['correct'] = (ministryStats[ministry]['correct'] as int) + 1;
      } else {
        ministryStats[ministry]['incorrect'] = (ministryStats[ministry]['incorrect'] as int) + 1;
      }
      stats['ministryStats'] = ministryStats;
    }
    
    print('[LocalStatisticsService] Updated stats: $stats');
    await _setStats(userId, stats);
    print('[LocalStatisticsService] Stats saved successfully');
  }

  Future<void> addStudyTimeMinutes({required String userId, required int minutes}) async {
    final stats = await getStats(userId);
    stats['studyTimeMinutes'] = (stats['studyTimeMinutes'] as int) + minutes;
    await _setStats(userId, stats);
  }

  Future<void> incrementTestCompleted({required String userId}) async {
    print('[LocalStatisticsService] incrementTestCompleted called - UserId: $userId');
    final stats = await getStats(userId);
    stats['totalTests'] = (stats['totalTests'] as int) + 1;
    print('[LocalStatisticsService] Total tests: ${stats['totalTests']}');
    await _setStats(userId, stats);
  }

  Future<void> clear(String userId) async {
    await _prefs.remove(_key(userId));
  }

  // Merge guest local stats into remote Firestore under the authenticated user
  Future<void> mergeGuestToRemote({required String userId, required FirestoreService firestore}) async {
    if (userId.isEmpty) return;
    final guest = await getStats('');
    if ((guest['totalQuestions'] as int) == 0 &&
        (guest['correct'] as int) == 0 &&
        (guest['incorrect'] as int) == 0 &&
        (guest['studyTimeMinutes'] as int) == 0) {
      return;
    }
    await firestore.upsertPerformanceSummary(
      userId: userId,
      data: {
        'totalQuestions': guest['totalQuestions'],
        'correct': guest['correct'],
        'incorrect': guest['incorrect'],
        'studyTimeMinutes': guest['studyTimeMinutes'],
      },
    );
    // Also store these under the authenticated user locally, then clear guest
    final current = await getStats(userId);
    await _setStats(userId, {
      'totalQuestions': (current['totalQuestions'] as int) + (guest['totalQuestions'] as int),
      'correct': (current['correct'] as int) + (guest['correct'] as int),
      'incorrect': (current['incorrect'] as int) + (guest['incorrect'] as int),
      'studyTimeMinutes': (current['studyTimeMinutes'] as int) + (guest['studyTimeMinutes'] as int),
    });
    await clear('');
  }
}


