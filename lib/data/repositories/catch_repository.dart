import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/catch_record.dart';

/// Repository for managing catch records.
class CatchRepository {
  static const String _storageKey = 'catch_records';

  final SharedPreferences _prefs;

  CatchRepository(this._prefs);

  /// Gets all catch records.
  List<CatchRecord> getAllCatches() {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString == null) return [];

    final jsonList = json.decode(jsonString) as List;
    return jsonList
        .map((item) => CatchRecord.fromJson(item as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Gets catches filtered by date range.
  List<CatchRecord> getCatchesByDateRange(DateTime start, DateTime end) {
    return getAllCatches()
        .where(
          (c) =>
              c.timestamp.isAfter(start) &&
              c.timestamp.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }

  /// Gets catches by species.
  List<CatchRecord> getCatchesBySpecies(String species) {
    return getAllCatches().where((c) => c.species == species).toList();
  }

  /// Gets recent catches (last 30 days).
  List<CatchRecord> getRecentCatches() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return getAllCatches()
        .where((c) => c.timestamp.isAfter(thirtyDaysAgo))
        .toList();
  }

  /// Adds a new catch record.
  Future<void> addCatch(CatchRecord catchRecord) async {
    final catches = getAllCatches();
    catches.add(catchRecord);
    await _saveCatches(catches);
  }

  /// Updates an existing catch record.
  Future<void> updateCatch(CatchRecord catchRecord) async {
    final catches = getAllCatches();
    final index = catches.indexWhere((c) => c.id == catchRecord.id);
    if (index != -1) {
      catches[index] = catchRecord;
      await _saveCatches(catches);
    }
  }

  /// Deletes a catch record.
  Future<void> deleteCatch(String id) async {
    final catches = getAllCatches();
    catches.removeWhere((c) => c.id == id);
    await _saveCatches(catches);
  }

  /// Gets statistics from catch records.
  Map<String, dynamic> getStatistics() {
    final catches = getAllCatches();
    if (catches.isEmpty) {
      return {
        'totalCatches': 0,
        'biggestCatch': null,
        'mostCaughtSpecies': null,
        'mostUsedBait': null,
        'fishingDays': 0,
      };
    }

    // Calculate stats
    final speciesCount = <String, int>{};
    final baitCount = <String, int>{};
    final uniqueDays = <String>{};
    double? biggestWeight;

    for (final c in catches) {
      speciesCount[c.species] = (speciesCount[c.species] ?? 0) + 1;
      baitCount[c.baitUsed] = (baitCount[c.baitUsed] ?? 0) + 1;
      uniqueDays.add(
        '${c.timestamp.year}-${c.timestamp.month}-${c.timestamp.day}',
      );
      if (c.weight != null) {
        biggestWeight = biggestWeight == null
            ? c.weight
            : (c.weight! > biggestWeight ? c.weight : biggestWeight);
      }
    }

    final topSpecies = speciesCount.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    final topBait = baitCount.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    return {
      'totalCatches': catches.length,
      'biggestCatch': biggestWeight,
      'mostCaughtSpecies': topSpecies.key,
      'mostUsedBait': topBait.key,
      'fishingDays': uniqueDays.length,
    };
  }

  Future<void> _saveCatches(List<CatchRecord> catches) async {
    final jsonList = catches.map((c) => c.toJson()).toList();
    await _prefs.setString(_storageKey, json.encode(jsonList));
  }
}
