import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../state/models.dart';

class CloudNotConfiguredException implements Exception {
  CloudNotConfiguredException(this.message);
  final String message;

  @override
  String toString() => message;
}

class CloudService {
  CloudService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Future<User> ensureSignedIn() async {
    final u = _auth.currentUser;
    if (u != null) return u;
    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) => _firestore.collection('users').doc(uid);
  DocumentReference<Map<String, dynamic>> _roomDoc(String roomId) => _firestore.collection('rooms').doc(roomId);

  CollectionReference<Map<String, dynamic>> _membersCol(String roomId) => _roomDoc(roomId).collection('members');
  CollectionReference<Map<String, dynamic>> _choresCol(String roomId) => _roomDoc(roomId).collection('chores');

  Future<String?> getMyRoomId() async {
    final u = await ensureSignedIn();
    final snap = await _userDoc(u.uid).get();
    if (!snap.exists) return null;
    final data = snap.data();
    return (data?['roomId'] as String?);
  }

  Future<void> setMyRoomId(String? roomId) async {
    final u = await ensureSignedIn();
    await _userDoc(u.uid).set(
      {
        'roomId': roomId,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<Room> createRoom({required String name, required String displayName}) async {
    final u = await ensureSignedIn();
    final roomRef = _firestore.collection('rooms').doc();
    final inviteCode = _generateInviteCode(roomRef.id);

    final batch = _firestore.batch();
    batch.set(roomRef, {
      'name': name.trim().isEmpty ? 'My Home' : name.trim(),
      'inviteCode': inviteCode,
      'ownerUid': u.uid,
      'memberOrder': [u.uid],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_membersCol(roomRef.id).doc(u.uid), {
      'name': displayName.trim().isEmpty ? 'You' : displayName.trim(),
      'isOwner': true,
      'joinedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_userDoc(u.uid), {
      'roomId': roomRef.id,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
    return Room(id: roomRef.id, name: name.trim().isEmpty ? 'My Home' : name.trim(), inviteCode: inviteCode);
  }

  Future<Room> joinRoom({required String inviteCode, required String displayName}) async {
    final u = await ensureSignedIn();

    final code = inviteCode.trim().toUpperCase();
    if (code.isEmpty) throw ArgumentError('Invite code is required');

    final q = await _firestore.collection('rooms').where('inviteCode', isEqualTo: code).limit(1).get();
    if (q.docs.isEmpty) throw StateError('Invalid invite code');

    final roomRef = q.docs.first.reference;

    await _firestore.runTransaction((tx) async {
      final roomSnap = await tx.get(roomRef);
      final data = roomSnap.data();
      if (data == null) throw StateError('Room not found');

      final order = (data['memberOrder'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
      if (!order.contains(u.uid)) {
        order.add(u.uid);
        tx.update(roomRef, {
          'memberOrder': order,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      tx.set(
        _membersCol(roomRef.id).doc(u.uid),
        {
          'name': displayName.trim().isEmpty ? 'You' : displayName.trim(),
          'isOwner': false,
          'joinedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      tx.set(
        _userDoc(u.uid),
        {
          'roomId': roomRef.id,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });

    final roomSnap = await roomRef.get();
    final roomData = roomSnap.data();
    return Room(
      id: roomRef.id,
      name: (roomData?['name'] as String?) ?? 'Shared Home',
      inviteCode: (roomData?['inviteCode'] as String?) ?? code,
    );
  }

  Future<void> leaveRoom(String roomId) async {
    final u = await ensureSignedIn();

    await _firestore.runTransaction((tx) async {
      final roomRef = _roomDoc(roomId);
      final roomSnap = await tx.get(roomRef);
      final data = roomSnap.data();
      if (data == null) return;

      final order = (data['memberOrder'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
      order.remove(u.uid);

      tx.update(roomRef, {
        'memberOrder': order,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.delete(_membersCol(roomId).doc(u.uid));
      tx.set(_userDoc(u.uid), {'roomId': null, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    });
  }

  Stream<Room?> watchRoom(String roomId) {
    return _roomDoc(roomId).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return null;
      return Room(
        id: snap.id,
        name: (data['name'] as String?) ?? 'Home',
        inviteCode: (data['inviteCode'] as String?),
      );
    });
  }

  Stream<List<Roommate>> watchMembers(String roomId) {
    return _membersCol(roomId).snapshots().map((snap) {
      return snap.docs.map((d) {
        final data = d.data();
        final name = (data['name'] as String?) ?? 'Roommate';
        return Roommate(id: d.id, name: name, isYou: d.id == _auth.currentUser?.uid);
      }).toList();
    });
  }

  Stream<List<Chore>> watchChores(String roomId) {
    return _choresCol(roomId).snapshots().map((snap) {
      return snap.docs.map((d) {
        final data = d.data();
        final historyRaw = (data['history'] as List<dynamic>? ?? []);
        final history = historyRaw
            .whereType<Map>()
          .map((e) => ChoreHistoryEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        return Chore(
          id: d.id,
          title: (data['title'] as String?) ?? 'Chore',
          createdAtIso: (data['createdAtIso'] as String?) ?? DateTime.now().toIso8601String(),
          repeatText: (data['repeatText'] as String?),
          currentTurnRoommateId: (data['currentTurnId'] as String?) ?? '',
          nextTurnRoommateId: (data['nextTurnId'] as String?) ?? '',
          history: history,
        );
      }).toList();
    });
  }

  Future<void> addChore({required String roomId, required String title, String? repeatText}) async {
    final u = await ensureSignedIn();
    final roomSnap = await _roomDoc(roomId).get();
    final data = roomSnap.data();
    if (data == null) throw StateError('Room not found');

    final order = (data['memberOrder'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    final current = order.isNotEmpty ? order.first : u.uid;
    final next = order.length >= 2 ? order[1] : current;

    await _choresCol(roomId).add({
      'title': title.trim(),
      'repeatText': repeatText,
      'createdAtIso': DateTime.now().toIso8601String(),
      'currentTurnId': current,
      'nextTurnId': next,
      'history': <Map<String, dynamic>>[],
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeChore({required String roomId, required String choreId}) async {
    await _choresCol(roomId).doc(choreId).delete();
  }

  Future<void> markChoreDone({required String roomId, required String choreId, required String expectedCurrentId}) async {
    final u = await ensureSignedIn();
    final roomRef = _roomDoc(roomId);
    final choreRef = _choresCol(roomId).doc(choreId);

    await _firestore.runTransaction((tx) async {
      final roomSnap = await tx.get(roomRef);
      final roomData = roomSnap.data();
      if (roomData == null) throw StateError('Room not found');

      final order = (roomData['memberOrder'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
      if (order.isEmpty) order.add(u.uid);

      final choreSnap = await tx.get(choreRef);
      final choreData = choreSnap.data();
      if (choreData == null) throw StateError('Chore not found');

      final current = (choreData['currentTurnId'] as String?) ?? '';
      if (current != expectedCurrentId) {
        throw StateError('Already completed or updated.');
      }

      final idx = order.indexOf(current);
      final safeIdx = idx >= 0 ? idx : 0;
      final nextIdx = (safeIdx + 1) % order.length;
      final next2Idx = (nextIdx + 1) % order.length;

      final next = order[nextIdx];
      final next2 = order[next2Idx];

      final history = (choreData['history'] as List<dynamic>? ?? []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      history.insert(0, {
        'id': _firestore.collection('_').doc().id,
        'completedByRoommateId': current,
        'completedAtIso': DateTime.now().toIso8601String(),
      });

      tx.update(choreRef, {
        'currentTurnId': next,
        'nextTurnId': next2,
        'history': history.take(20).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  String _generateInviteCode(String roomId) {
    // Stable 6-char invite code derived from docId (not cryptographic).
    final cleaned = roomId.replaceAll('-', '').toUpperCase();
    return cleaned.substring(cleaned.length - 6);
  }
}
