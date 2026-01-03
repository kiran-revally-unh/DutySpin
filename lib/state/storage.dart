import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

const _storageKey = 'dutyspin.state.v1';
const _legacyStorageKey = 'choreflow_flutter.state.v1';

class StateStorage {
  Future<PersistedState?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey) ?? prefs.getString(_legacyStorageKey);
      if (raw == null || raw.isEmpty) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return PersistedState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(PersistedState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toJson()));
    } catch (_) {
      // ignore
    }
  }

  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (_) {
      // ignore
    }
  }
}
