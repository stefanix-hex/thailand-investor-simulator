import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/game_state.dart';

class SaveService {
  static const _boxName = 'tis_saves';
  static const _key = 'campaign';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_boxName);
  }

  static Box<String> get _box => Hive.box<String>(_boxName);

  static Future<void> save(GameState state) async {
    await _box.put(_key, jsonEncode(state.toJson()));
  }

  static GameState? load() {
    final raw = _box.get(_key);
    if (raw == null) return null;
    try {
      return GameState.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return null;
    }
  }

  static bool get hasSave => _box.containsKey(_key);

  static Future<void> clear() async {
    await _box.delete(_key);
  }
}
