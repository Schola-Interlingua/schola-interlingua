import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/learning_practice.dart';

class LearningPracticeStore extends ChangeNotifier {
  LearningPracticeStore();
  static final instance = LearningPracticeStore();
  static const storageKey = 'learning_practice_events_v1';
  final List<PracticeEvent> _events = [];
  List<PracticeEvent> get events => List.unmodifiable(_events);
  SharedPreferences? _prefs;
  Future<void>? _loading;
  Future<void> _writes = Future.value();

  Future<void> load() => _loading ??= _load().catchError((Object error) {
    _loading = null;
    throw error;
  });
  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(storageKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as List;
      _events.addAll(
        decoded.map(
          (item) =>
              PracticeEvent.fromJson(Map<String, dynamic>.from(item as Map)),
        ),
      );
    }
  }

  Future<void> append(PracticeEvent event) {
    final operation = _writes.then((_) async {
      await load();
      if (_events.any((item) => item.id == event.id)) return;
      final updated = [..._events, event];
      final saved = await _prefs!.setString(
        storageKey,
        jsonEncode(updated.map((item) => item.toJson()).toList()),
      );
      if (!saved) throw StateError('Practice history could not be saved');
      _events.add(event);
      notifyListeners();
    });
    _writes = operation.catchError((Object _) {});
    return operation;
  }

  List<PracticeEvent> forSource(String slug) =>
      _events.where((event) => event.sourceSlug == slug).toList();
}
