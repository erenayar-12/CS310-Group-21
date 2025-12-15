import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../data/habit.dart';
import '../data/habit_group.dart';

class FirestoreService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
        .where('createdBy', isEqualTo: user.uid)
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
          .where('createdBy', isEqualTo: user.uid)
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
        'userId': user.uid,
        'completedAt': Timestamp.fromDate(completedAt),
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getHabitCompletionsStream(String habitId) {
    return _firestore
        .collection('habitCompletions')
        .where('habitId', isEqualTo: habitId)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'completedAt': (data['completedAt'] as Timestamp?)?.toDate(),
        };
      }).toList();
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
}
