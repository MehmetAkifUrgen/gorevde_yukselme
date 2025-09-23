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
      };

  Future<Map<String, dynamic>> getStats(String userId) async {
    final raw = _prefs.getString(_key(userId));
    if (raw == null || raw.isEmpty) return _empty();
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return {
        ..._empty(),
        ...map,
      };
    } catch (_) {
      return _empty();
    }
  }

  Future<void> _setStats(String userId, Map<String, dynamic> stats) async {
    await _prefs.setString(_key(userId), json.encode(stats));
  }

  Future<void> incrementQuestion({required String userId, required bool isCorrect}) async {
    final stats = await getStats(userId);
    stats['totalQuestions'] = (stats['totalQuestions'] as int) + 1;
    if (isCorrect) {
      stats['correct'] = (stats['correct'] as int) + 1;
    } else {
      stats['incorrect'] = (stats['incorrect'] as int) + 1;
    }
    await _setStats(userId, stats);
  }

  Future<void> addStudyTimeMinutes({required String userId, required int minutes}) async {
    final stats = await getStats(userId);
    stats['studyTimeMinutes'] = (stats['studyTimeMinutes'] as int) + minutes;
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


