import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs;

  FavoritesService({
    FirebaseFirestore? firestore,
    required SharedPreferences sharedPreferences,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _prefs = sharedPreferences;

  String _prefsKey(String userId) => 'starred_question_ids_${userId.isEmpty ? 'guest' : userId}';

  Future<Set<String>> getLocalStarredIds(String userId) async {
    // Debug
    // ignore: avoid_print
    print('[FavoritesService] getLocalStarredIds userId=$userId');
    final key = _prefsKey(userId);
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return <String>{};
    try {
      final decoded = json.decode(raw);
      if (decoded is List) {
        final set = decoded.cast<String>().toSet();
        // Fix old ID format
        final fixedSet = _fixOldIdFormat(set);
        if (fixedSet.length != set.length) {
          // Save fixed IDs
          await setLocalStarredIds(userId, fixedSet);
        }
        // ignore: avoid_print
        print('[FavoritesService] Local starred count=${fixedSet.length}');
        return fixedSet;
      }
      return <String>{};
    } catch (_) {
      return <String>{};
    }
  }

  /// Fixes old ID format to match new format
  Set<String> _fixOldIdFormat(Set<String> ids) {
    final fixedIds = <String>{};
    for (final id in ids) {
      // Old format: Görevde Yükselme_İdare Memuru_2017 Çıkmış Sorular_72
      // New format: Görevde Yükselme_İdare Memuru_2017 İdare Memuru Çıkmış Sorular 1_72
      if (id.contains('_2017 Çıkmış Sorular_')) {
        // Extract parts
        final parts = id.split('_');
        if (parts.length >= 4) {
          final category = parts[0];
          final profession = parts[1];
          final oldSubject = parts[2];
          final questionNo = parts[3];
          
          // Fix subject format
          final newSubject = oldSubject.replaceAll('2017 Çıkmış Sorular', '2017 $profession Çıkmış Sorular 1');
          final newId = '${category}_${profession}_${newSubject}_${questionNo}';
          fixedIds.add(newId);
          // ignore: avoid_print
          print('[FavoritesService] Fixed ID: $id -> $newId');
        } else {
          fixedIds.add(id);
        }
      } else {
        fixedIds.add(id);
      }
    }
    return fixedIds;
  }

  Future<void> setLocalStarredIds(String userId, Set<String> ids) async {
    final key = _prefsKey(userId);
    await _prefs.setString(key, json.encode(ids.toList()));
  }

  Future<Set<String>> getRemoteStarredIds(String userId) async {
    if (userId.isEmpty) return <String>{};
    try {
      // ignore: avoid_print
      print('[FavoritesService] getRemoteStarredIds userId=$userId');
      final snap = await _firestore.collection('users').doc(userId).get();
      final data = snap.data();
      if (data == null) return <String>{};
      final list = data['starredQuestionIds'];
      if (list is List) {
        final set = list.cast<String>().toSet();
        // ignore: avoid_print
        print('[FavoritesService] Remote starred count=${set.length}');
        return set;
      }
      return <String>{};
    } catch (_) {
      return <String>{};
    }
  }

  Future<Set<String>> syncFromRemote(String userId) async {
    final remote = await getRemoteStarredIds(userId);
    final local = await getLocalStarredIds(userId);
    
    // ignore: avoid_print
    print('[FavoritesService] syncFromRemote received ${remote.length} ids, local has ${local.length} ids');
    
    if (userId.isEmpty) {
      // Guest user - just return local data
      return local;
    }
    
    if (remote.isEmpty && local.isNotEmpty) {
      // No remote data but local data exists - upload local to remote
      try {
        // ignore: avoid_print
        print('[FavoritesService] Uploading ${local.length} local favorites to remote');
        await _firestore.collection('users').doc(userId).set({
          'starredQuestionIds': local.toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return local;
      } catch (e) {
        // ignore: avoid_print
        print('[FavoritesService] Failed to upload local favorites: $e');
        return local;
      }
    } else if (remote.isNotEmpty) {
      // Remote data exists - merge with local and update both
      final merged = {...remote, ...local};
      if (merged.length != remote.length) {
        try {
          // ignore: avoid_print
          print('[FavoritesService] Merging ${local.length} local with ${remote.length} remote favorites');
          await _firestore.collection('users').doc(userId).update({
            'starredQuestionIds': merged.toList(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          await setLocalStarredIds(userId, merged);
          return merged;
        } catch (e) {
          // ignore: avoid_print
          print('[FavoritesService] Failed to merge favorites: $e');
          await setLocalStarredIds(userId, remote);
          return remote;
        }
      } else {
        // No new local data - just sync remote to local
        await setLocalStarredIds(userId, remote);
        return remote;
      }
    }
    
    return remote;
  }

  Future<void> setStarStatus({
    required String userId,
    required String questionId,
    required bool isStarred,
  }) async {
    // Update local first for instant UX
    final local = await getLocalStarredIds(userId);
    if (isStarred) {
      local.add(questionId);
    } else {
      local.remove(questionId);
    }
    await setLocalStarredIds(userId, local);

    // Best-effort remote update
    if (userId.isEmpty) return;
    try {
      // ignore: avoid_print
      print('[FavoritesService] setStarStatus userId=$userId qId=$questionId isStarred=$isStarred');
      final docRef = _firestore.collection('users').doc(userId);
      if (isStarred) {
        await docRef.update({
          'starredQuestionIds': FieldValue.arrayUnion([questionId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.update({
          'starredQuestionIds': FieldValue.arrayRemove([questionId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      // Ignore to keep UI responsive; local cache remains
    }
  }
}


