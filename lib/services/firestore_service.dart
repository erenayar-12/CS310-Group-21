import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../data/habit.dart';
import '../data/habit_group.dart';

class FirestoreService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // USER XP
  DocumentReference<Map<String, dynamic>> get _userStatsRef {
    final user = _auth.currentUser;
    if (user == null) {
      throw 'User must be authenticated';
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('meta')
        .doc('stats');
  }
  DocumentReference<Map<String, dynamic>>? _userStatsRefOrNull() {
    final user = _auth.currentUser;
    if (user == null) return null;

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('meta')
        .doc('stats');
  }


  Stream<int> getTotalXpStream() {
    final ref = _userStatsRefOrNull();
    if (ref == null) return Stream.value(0);

    return ref.snapshots().map((doc) {
      final data = doc.data();
      return (data?['totalXp'] as num?)?.toInt() ?? 0;
    });
  }

  Stream<Map<String, dynamic>> getUserStatsStream() {
    final ref = _userStatsRefOrNull();
    if (ref == null) return Stream.value(<String, dynamic>{});

    return ref.snapshots().map((doc) => doc.data() ?? <String, dynamic>{});
  }

  Stream<int> getTotalCompletionsStream() {
    final ref = _userStatsRefOrNull();
    if (ref == null) return Stream.value(0);

    return ref.snapshots().map((doc) {
      final data = doc.data();
      return (data?['totalCompletions'] as num?)?.toInt() ?? 0;
    });
  }



  Future<void> addXp(int amount) async {
    final ref = _userStatsRefOrNull();
    if (ref == null) throw 'User must be authenticated';

    await ref.set(
      {
        'totalXp': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> grantAchievementXpOnce({
    required String achievementId,
    required int xp,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('meta')
        .doc('stats');

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() ?? {};

      final List<dynamic> unlocked =
          (data['unlockedAchievements'] as List<dynamic>?) ?? [];

      // Already granted -> do nothing
      if (unlocked.contains(achievementId)) return;

      // First time -> add id + add XP
      tx.set(
        ref,
        {
          'unlockedAchievements': FieldValue.arrayUnion([achievementId]),
          'totalXp': FieldValue.increment(xp),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  Stream<List<String>> getUnlockedAchievementIdsStream() {
    final ref = _userStatsRefOrNull();
    if (ref == null) return Stream.value(const []);

    return ref.snapshots().map((doc) {
      final data = doc.data();
      final raw = (data?['unlockedAchievements'] as List<dynamic>?) ?? const [];
      return raw.map((e) => e.toString()).toList();
    });
  }

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<String> createHabit(Habit habit) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'User must be authenticated to create a habit';
      }

      final habitData = habit.toFirestore();
      habitData['createdBy'] = user.uid;
      habitData['createdAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore.collection('habits').add(habitData);
      _setLoading(false);
      return docRef.id;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  Future<Habit?> getHabit(String habitId) async {
    _setLoading(true);
    _setError(null);
    try {
      final doc = await _firestore.collection('habits').doc(habitId).get();
      if (!doc.exists) {
        _setLoading(false);
        return null;
      }

      final data = doc.data()!;
    
      final createdAt = data['createdAt'];
      final createdAtDateTime = createdAt is Timestamp
          ? createdAt.toDate()
          : createdAt is DateTime
              ? createdAt
              : null;
      
      _setLoading(false);
      return Habit.fromMap({
        ...data,
        'id': doc.id,
        'createdAt': createdAtDateTime?.toIso8601String(),
      });
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      throw 'Failed to get habit: $e';
    }
  }

  Stream<List<Habit>> getHabitsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('habits')
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final createdAt = data['createdAt'];
        final createdAtDateTime = createdAt is Timestamp
            ? createdAt.toDate()
            : createdAt is DateTime
                ? createdAt
                : null;
        
        return Habit.fromMap({
          ...data,
          'id': doc.id,
          'createdAt': createdAtDateTime?.toIso8601String(),
        });
      }).toList();
    });
  }

  Future<List<Habit>> getHabits() async {
    _setLoading(true);
    _setError(null);
    final user = _auth.currentUser;
    if (user == null) {
      _setLoading(false);
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('habits')
          .where('createdBy', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final habits = snapshot.docs.map((doc) {
        final data = doc.data();
        final createdAt = data['createdAt'];
        final createdAtDateTime = createdAt is Timestamp
            ? createdAt.toDate()
            : createdAt is DateTime
                ? createdAt
                : null;
        
        return Habit.fromMap({
          ...data,
          'id': doc.id,
          'createdAt': createdAtDateTime?.toIso8601String(),
        });
      }).toList();
      
      _setLoading(false);
      return habits;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      throw 'Failed to get habits: $e';
    }
  }

  Future<void> updateHabit(String habitId, Habit habit) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'User must be authenticated to update a habit';
      }

      final doc = await _firestore.collection('habits').doc(habitId).get();
      if (!doc.exists) {
        throw 'Habit not found';
      }
      if (doc.data()?['createdBy'] != user.uid) {
        throw 'You can only update your own habits';
      }

      final habitData = habit.toFirestore();
      habitData.remove('createdBy');
      habitData.remove('createdAt');

      await _firestore.collection('habits').doc(habitId).update(habitData);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> deleteHabit(String habitId) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'User must be authenticated to delete a habit';
      }

      final doc = await _firestore.collection('habits').doc(habitId).get();
      if (!doc.exists) {
        throw 'Habit not found';
      }
      if (doc.data()?['createdBy'] != user.uid) {
        throw 'You can only delete your own habits';
      }

      await _firestore.collection('habits').doc(habitId).delete();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  Future<String> createHabitGroup(HabitGroup group) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'User must be authenticated to create a habit group';
      }

      final groupData = group.toFirestore();
      List<String> currentMembers = List<String>.from(groupData['members'] ?? []);
      if (!currentMembers.contains(user.uid)) {
        currentMembers.add(user.uid);
      }

      groupData['members'] = currentMembers; // Update the list
      groupData['totalMembers'] = currentMembers.length; // Sync the count
      groupData['createdBy'] = user.uid;
      groupData['createdAt'] = FieldValue.serverTimestamp();
      final docRef = await _firestore.collection('habitGroups').add(groupData);
      _setLoading(false);
      return docRef.id;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  Future<HabitGroup?> getHabitGroup(String groupId) async {
    _setLoading(true);
    _setError(null);
    try {
      final doc = await _firestore.collection('habitGroups').doc(groupId).get();
      if (!doc.exists) {
        _setLoading(false);
        return null;
      }

      final data = doc.data()!;
    
      final createdAt = data['createdAt'];
      if (createdAt is Timestamp) {
        data['createdAt'] = createdAt.toDate();
      }
      
      _setLoading(false);
      return HabitGroup.fromFirestore(data, doc.id);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      throw 'Failed to get habit group: $e';
    }
  }

  Stream<List<HabitGroup>> getHabitGroupsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('habitGroups')
        .where('members', arrayContains: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        final createdAt = data['createdAt'];
        if (createdAt is Timestamp) {
          data['createdAt'] = createdAt.toDate();
        }
        return HabitGroup.fromFirestore(data, doc.id);
      }).toList();
    });
  }

  Future<List<HabitGroup>> getHabitGroups() async {
    _setLoading(true);
    _setError(null);
    final user = _auth.currentUser;
    if (user == null) {
      _setLoading(false);
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('habitGroups')
          .where('members', arrayContains: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final groups = snapshot.docs.map((doc) {
        final data = doc.data();
        
        final createdAt = data['createdAt'];
        if (createdAt is Timestamp) {
          data['createdAt'] = createdAt.toDate();
        }
        return HabitGroup.fromFirestore(data, doc.id);
      }).toList();
      
      _setLoading(false);
      return groups;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      throw 'Failed to get habit groups: $e';
    }
  }

  Stream<List<HabitGroup>> getPublicHabitGroupsStream() {
    return _firestore
        .collection('habitGroups')
        .where('status', isEqualTo: 'onTrack')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final createdAt = data['createdAt'];
        if (createdAt is Timestamp) {
          data['createdAt'] = createdAt.toDate();
        }
        return HabitGroup.fromFirestore(data, doc.id);
      }).toList();
    });
  }

  Future<void> updateHabitGroup(String groupId, HabitGroup group) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'User must be authenticated to update a habit group';
      }

      final doc = await _firestore.collection('habitGroups').doc(groupId).get();
      if (!doc.exists) {
        throw 'Habit group not found';
      }
      if (doc.data()?['createdBy'] != user.uid) {
        throw 'You can only update your own habit groups';
      }

      final groupData = group.toFirestore();
      groupData.remove('createdBy');
      groupData.remove('createdAt');

      await _firestore.collection('habitGroups').doc(groupId).update(groupData);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> deleteHabitGroup(String groupId) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'User must be authenticated to delete a habit group';
      }

      final doc = await _firestore.collection('habitGroups').doc(groupId).get();
      if (!doc.exists) {
        throw 'Habit group not found';
      }
      if (doc.data()?['createdBy'] != user.uid) {
        throw 'You can only delete your own habit groups';
      }

      await _firestore.collection('habitGroups').doc(groupId).delete();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> createHabitCompletion({
    required String habitId,
    String? habitName,
    String? habitEmoji,
    required DateTime completedAt,
    String? notes,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'User must be authenticated to create a habit completion';
      }

      await _firestore.collection('habitCompletions').add({
        'habitId': habitId,
        'habitName': habitName,
        'habitEmoji': habitEmoji,
        'userId': user.uid,
        'completedAt': Timestamp.fromDate(completedAt),
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _userStatsRef.set(
        {
          'totalXp': FieldValue.increment(10),
          'totalCompletions': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getHabitCompletionsStream(String habitId) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('habitCompletions')
        .where('habitId', isEqualTo: habitId)
        .where('userId', isEqualTo: userId) // CRITICAL: Matches Security Rules
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }



// Replace your existing getUserCompletionsStream with this:
  Stream<List<Map<String, dynamic>>> getUserCompletionsStream({int limit = 300}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('habitCompletions')
        .where('userId', isEqualTo: user.uid)
        .limit(limit)
        .snapshots()
        .map((snapshot) {

      final dataList = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'completedAt': data['completedAt'] is Timestamp
              ? (data['completedAt'] as Timestamp).toDate()
              : null,
        };
      }).toList();

      dataList.sort((a, b) {
        final dateA = a['completedAt'] as DateTime?;
        final dateB = b['completedAt'] as DateTime?;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });

      return dataList;
    });
  }

  Future<void> deleteHabitCompletion(String completionId) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'User must be authenticated to delete a habit completion';
      }

      final doc = await _firestore.collection('habitCompletions').doc(completionId).get();
      if (!doc.exists) {
        throw 'Habit completion not found';
      }
      if (doc.data()?['userId'] != user.uid) {
        throw 'You can only delete your own habit completions';
      }

      await _firestore.collection('habitCompletions').doc(completionId).delete();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> updateUserProfile(String name, String goal) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User must be authenticated';

    await _firestore.collection('users').doc(user.uid).set({
      'username': name.trim(), // We use 'username' as the new standard
      'dailyGoal': goal.trim(),
      'email': user.email,
    }, SetOptions(merge: true)); // This ensures old users get their doc created
  }

  Future<void> incrementGroupProgress(String groupId) async {
    final groupRef = _firestore.collection('habitGroups').doc(groupId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(groupRef);
      if (!snapshot.exists) return;

      final currentProgress = snapshot.data()?['todayProgress'] ?? 0;
      final totalMembers = snapshot.data()?['totalMembers'] ?? 1;

      if (currentProgress < totalMembers) {
        transaction.update(groupRef, {
          'todayProgress': FieldValue.increment(1),
        });
      }
    });
  }
}
