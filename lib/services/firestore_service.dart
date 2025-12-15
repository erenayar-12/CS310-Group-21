import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/habit.dart';
import '../data/habit_group.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;



  Future<String> createHabit(Habit habit) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw 'User must be authenticated to create a habit';
    }

    final habitData = habit.toFirestore();
    habitData['createdBy'] = user.uid;
    habitData['createdAt'] = FieldValue.serverTimestamp();

    final docRef = await _firestore.collection('habits').add(habitData);
    return docRef.id;
  }

  Future<Habit?> getHabit(String habitId) async {
    try {
      final doc = await _firestore.collection('habits').doc(habitId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
    
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
    } catch (e) {
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
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('habits')
          .where('createdBy', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

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
    } catch (e) {
      throw 'Failed to get habits: $e';
    }
  }

  Future<void> updateHabit(String habitId, Habit habit) async {
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
  }

  Future<void> deleteHabit(String habitId) async {
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
  }

  

  Future<String> createHabitGroup(HabitGroup group) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw 'User must be authenticated to create a habit group';
    }

    final groupData = group.toFirestore();
    groupData['createdBy'] = user.uid;
    groupData['createdAt'] = FieldValue.serverTimestamp();

    final docRef = await _firestore.collection('habitGroups').add(groupData);
    return docRef.id;
  }

  Future<HabitGroup?> getHabitGroup(String groupId) async {
    try {
      final doc = await _firestore.collection('habitGroups').doc(groupId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
    
      final createdAt = data['createdAt'];
      if (createdAt is Timestamp) {
        data['createdAt'] = createdAt.toDate();
      }
      
      return HabitGroup.fromFirestore(data, doc.id);
    } catch (e) {
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
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('habitGroups')
          .where('createdBy', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        final createdAt = data['createdAt'];
        if (createdAt is Timestamp) {
          data['createdAt'] = createdAt.toDate();
        }
        return HabitGroup.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
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
  }

  Future<void> deleteHabitGroup(String groupId) async {
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
  }



  Future<void> createHabitCompletion({
    required String habitId,
    required DateTime completedAt,
    String? notes,
  }) async {
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
  }
}

