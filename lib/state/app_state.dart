import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

import 'models.dart';
import 'storage.dart';
import '../services/cloud_service.dart';

class AppState extends ChangeNotifier {
  AppState({StateStorage? storage, required this.firebaseReady}) : _storage = storage ?? StateStorage();

  final bool firebaseReady;

  final StateStorage _storage;
  final _uuid = const Uuid();

  CloudService? _cloud;
  StreamSubscription<Room?>? _roomSub;
  StreamSubscription<List<Roommate>>? _membersSub;
  StreamSubscription<List<Chore>>? _choresSub;

  bool _hydrated = false;
  bool get hydrated => _hydrated;

  bool onboardingComplete = false;
  bool proUnlocked = false;

  // Session-only auth: not persisted. This matches the "OTP each time" flow.
  bool authenticated = false;

  // Session-only OTP challenge: not persisted.
  String? _otpDestination;
  String? _otpCode;
  DateTime? _otpExpiresAt;

  Room? room;
  List<Roommate> roommates = [];
  List<Chore> chores = [];
  Preferences preferences = Preferences.defaults();

  Future<void> hydrate() async {
    final loaded = await _storage.load();
    if (loaded != null) {
      onboardingComplete = loaded.onboardingComplete;
      proUnlocked = loaded.proUnlocked;
      room = loaded.room;
      roommates = _ensureYou(loaded.roommates);
      chores = loaded.chores;
      preferences = loaded.preferences;
    } else {
      roommates = _ensureYou(roommates);
    }

    _hydrated = true;
    notifyListeners();
  }

  Future<void> _ensureCloudReady() async {
    if (!firebaseReady) return;
    _cloud ??= CloudService();
    try {
      await _cloud!.ensureSignedIn();
    } catch (_) {
      // If Firebase isn't fully configured on this platform, stay in local mode.
      _cloud = null;
    }
  }

  Future<void> _subscribeToCloudRoom(String roomId) async {
    await _ensureCloudReady();
    if (_cloud == null) return;

    await _roomSub?.cancel();
    await _membersSub?.cancel();
    await _choresSub?.cancel();

    _roomSub = _cloud!.watchRoom(roomId).listen((r) {
      room = r;
      notifyListeners();
      _persist();
    });

    _membersSub = _cloud!.watchMembers(roomId).listen((list) {
      roommates = _ensureYou(list);
      notifyListeners();
      _persist();
    });

    _choresSub = _cloud!.watchChores(roomId).listen((list) {
      chores = list;
      notifyListeners();
      _persist();
    });
  }

  bool get hasActiveOtp {
    if (_otpCode == null || _otpExpiresAt == null) return false;
    return DateTime.now().isBefore(_otpExpiresAt!);
  }

  String? get otpDestination => _otpDestination;

  Duration? get otpTimeRemaining {
    if (_otpExpiresAt == null) return null;
    final d = _otpExpiresAt!.difference(DateTime.now());
    if (d.isNegative) return Duration.zero;
    return d;
  }

  void setAuthenticated(bool value) {
    authenticated = value;
    notifyListeners();

    if (!value) {
      _roomSub?.cancel();
      _membersSub?.cancel();
      _choresSub?.cancel();
      _roomSub = null;
      _membersSub = null;
      _choresSub = null;
      return;
    }

    // Best-effort cloud hydration when Firebase is available.
    unawaited(() async {
      await _ensureCloudReady();
      if (_cloud == null) return;
      final roomId = await _cloud!.getMyRoomId();
      if (roomId == null || roomId.isEmpty) return;
      await _subscribeToCloudRoom(roomId);
    }());
  }

  /// Creates a new 6-digit OTP challenge for the given destination.
  /// In a real build, this would call the backend (Firebase/Auth API).
  void startOtpChallenge({required String destination}) {
    _otpDestination = destination;
    // Pseudo-random but deterministic enough for a demo.
    final seed = DateTime.now().microsecondsSinceEpoch % 900000;
    _otpCode = (100000 + seed).toString().padLeft(6, '0');
    _otpExpiresAt = DateTime.now().add(const Duration(minutes: 5));
    notifyListeners();
  }

  bool verifyOtpCode(String entered) {
    final c = entered.trim();
    if (c.length != 6) return false;
    if (_otpCode == null || _otpExpiresAt == null) return false;
    if (DateTime.now().isAfter(_otpExpiresAt!)) return false;
    return c == _otpCode;
  }

  void clearOtpChallenge() {
    _otpDestination = null;
    _otpCode = null;
    _otpExpiresAt = null;
    notifyListeners();
  }

  Future<void> _persist() async {
    if (!_hydrated) return;
    final snapshot = PersistedState(
      onboardingComplete: onboardingComplete,
      proUnlocked: proUnlocked,
      room: room,
      roommates: roommates,
      chores: chores,
      preferences: preferences,
    );
    await _storage.save(snapshot);
  }

  List<Roommate> _ensureYou(List<Roommate> list) {
    if (list.any((r) => r.isYou)) return list;
    return [Roommate(id: _uuid.v4(), name: 'You', isYou: true), ...list];
  }

  String _inviteCode() {
    final v = _uuid.v4().replaceAll('-', '');
    return v.substring(v.length - 6).toUpperCase();
  }

  String _pickInitialTurnId() {
    final you = roommates.where((r) => r.isYou).toList();
    if (you.isNotEmpty) return you.first.id;
    if (roommates.isNotEmpty) return roommates.first.id;
    final fallback = Roommate(id: _uuid.v4(), name: 'You', isYou: true);
    roommates = [fallback];
    return fallback.id;
  }

  ({String current, String next}) _computeNextTurn(String currentId) {
    if (roommates.isEmpty) {
      return (current: currentId, next: currentId);
    }
    final idx = roommates.indexWhere((r) => r.id == currentId);
    final safeIdx = idx >= 0 ? idx : 0;
    final nextIdx = (safeIdx + 1) % roommates.length;
    return (current: roommates[safeIdx].id, next: roommates[nextIdx].id);
  }

  Future<void> reset() async {
    await _storage.clear();
    onboardingComplete = false;
    proUnlocked = false;
    authenticated = false;
    clearOtpChallenge();
    await _roomSub?.cancel();
    await _membersSub?.cancel();
    await _choresSub?.cancel();
    _roomSub = null;
    _membersSub = null;
    _choresSub = null;
    room = null;
    roommates = _ensureYou([]);
    chores = [];
    preferences = Preferences.defaults();
    notifyListeners();
  }

  Future<void> createRoom(String roomName) async {
    final trimmed = roomName.trim().isEmpty ? 'My Home' : roomName.trim();

    await _ensureCloudReady();
    if (authenticated && _cloud != null) {
      final displayName = roommates.where((r) => r.isYou).isNotEmpty ? roommates.firstWhere((r) => r.isYou).name : 'You';
      final created = await _cloud!.createRoom(name: trimmed, displayName: displayName);
      room = created;
      notifyListeners();
      await _persist();
      await _subscribeToCloudRoom(created.id);
      return;
    }

    room = Room(id: _uuid.v4(), name: trimmed, inviteCode: _inviteCode());
    roommates = _ensureYou(roommates);
    notifyListeners();
    await _persist();
  }

  Future<void> joinRoom(String inviteCode) async {
    final code = inviteCode.trim().toUpperCase();

    await _ensureCloudReady();
    if (authenticated && _cloud != null) {
      final displayName = roommates.where((r) => r.isYou).isNotEmpty ? roommates.firstWhere((r) => r.isYou).name : 'You';
      final joined = await _cloud!.joinRoom(inviteCode: code, displayName: displayName);
      room = joined;
      notifyListeners();
      await _persist();
      await _subscribeToCloudRoom(joined.id);
      return;
    }

    room = Room(id: _uuid.v4(), name: 'Shared Home', inviteCode: code);
    roommates = _ensureYou(roommates);
    notifyListeners();
    await _persist();
  }

  Future<void> leaveRoom() async {
    final r = room;
    if (r == null) return;

    await _ensureCloudReady();
    if (authenticated && _cloud != null) {
      await _cloud!.leaveRoom(r.id);
    }

    room = null;
    chores = [];
    roommates = _ensureYou([]);
    notifyListeners();
    await _persist();
  }

  Future<void> setRoomName(String name) async {
    if (room == null) return;
    room = Room(id: room!.id, name: name, inviteCode: room!.inviteCode);
    notifyListeners();
    await _persist();
  }

  Future<void> addRoommate({required String name, String? email}) async {
    final n = name.trim();
    if (n.isEmpty) return;
    roommates = _ensureYou([...roommates, Roommate(id: _uuid.v4(), name: n, email: email?.trim().isEmpty == true ? null : email?.trim())]);
    _reconcileChoreTurns();
    notifyListeners();
    await _persist();
  }

  Future<void> removeRoommate(String roommateId) async {
    final rm = roommates.firstWhere((r) => r.id == roommateId, orElse: () => Roommate(id: '', name: ''));
    if (rm.id.isEmpty || rm.isYou) return;
    roommates = _ensureYou(roommates.where((r) => r.id != roommateId).toList());
    _reconcileChoreTurns();
    notifyListeners();
    await _persist();
  }

  void _reconcileChoreTurns() {
    for (var i = 0; i < chores.length; i += 1) {
      final c = chores[i];
      final currentExists = roommates.any((r) => r.id == c.currentTurnRoommateId);
      final nextExists = roommates.any((r) => r.id == c.nextTurnRoommateId);
      if (currentExists && nextExists) continue;
      final fallbackCurrent = _pickInitialTurnId();
      final turn = _computeNextTurn(fallbackCurrent);
      chores[i] = Chore(
        id: c.id,
        title: c.title,
        createdAtIso: c.createdAtIso,
        repeatText: c.repeatText,
        currentTurnRoommateId: turn.current,
        nextTurnRoommateId: turn.next,
        history: c.history,
      );
    }
  }

  Future<void> addChore(String title) async {
    if (room == null) return;
    final t = title.trim();
    if (t.isEmpty) return;

    await _ensureCloudReady();
    if (authenticated && _cloud != null) {
      await _cloud!.addChore(roomId: room!.id, title: t);
      return;
    }

    roommates = _ensureYou(roommates);
    final initial = _pickInitialTurnId();
    final turn = _computeNextTurn(initial);

    final chore = Chore(
      id: _uuid.v4(),
      title: t,
      createdAtIso: DateTime.now().toIso8601String(),
      currentTurnRoommateId: turn.current,
      nextTurnRoommateId: turn.next,
      history: const [],
    );

    chores = [chore, ...chores];
    notifyListeners();
    await _persist();
  }

  Future<void> removeChore(String choreId) async {
    await _ensureCloudReady();
    if (room != null && authenticated && _cloud != null) {
      await _cloud!.removeChore(roomId: room!.id, choreId: choreId);
      return;
    }

    chores = chores.where((c) => c.id != choreId).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> markChoreDone(String choreId) async {
    await _ensureCloudReady();
    if (room != null && authenticated && _cloud != null) {
      final existing = chores.where((c) => c.id == choreId).isNotEmpty ? chores.firstWhere((c) => c.id == choreId) : null;
      if (existing == null) return;
      await _cloud!.markChoreDone(roomId: room!.id, choreId: choreId, expectedCurrentId: existing.currentTurnRoommateId);
      return;
    }

    chores = chores.map((c) {
      if (c.id != choreId) return c;

      final entry = ChoreHistoryEntry(
        id: _uuid.v4(),
        completedByRoommateId: c.currentTurnRoommateId,
        completedAtIso: DateTime.now().toIso8601String(),
      );

      final next1 = _computeNextTurn(c.currentTurnRoommateId);
      final next2 = _computeNextTurn(next1.next);

      return Chore(
        id: c.id,
        title: c.title,
        createdAtIso: c.createdAtIso,
        repeatText: c.repeatText,
        currentTurnRoommateId: next1.next,
        nextTurnRoommateId: next2.next,
        history: [entry, ...c.history].take(20).toList(),
      );
    }).toList();

    notifyListeners();
    await _persist();
  }

  Future<void> setOnboardingComplete(bool value) async {
    onboardingComplete = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setProUnlocked(bool value) async {
    proUnlocked = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setPreferences({bool? pushNotificationsEnabled, String? reminderFrequency, bool? doNotDisturbEnabled}) async {
    preferences = Preferences(
      pushNotificationsEnabled: pushNotificationsEnabled ?? preferences.pushNotificationsEnabled,
      reminderFrequency: reminderFrequency ?? preferences.reminderFrequency,
      doNotDisturbEnabled: doNotDisturbEnabled ?? preferences.doNotDisturbEnabled,
    );
    notifyListeners();
    await _persist();
  }

  Roommate? roommateById(String id) {
    try {
      return roommates.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
