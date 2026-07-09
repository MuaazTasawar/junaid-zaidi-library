import 'package:equatable/equatable.dart';

/// LibConnect-side saved search model (Screen 19). Client-only —
/// persisted in Hive, not a Koha resource.
class SavedSearch extends Equatable {
  const SavedSearch({
    required this.id,
    required this.term,
    required this.resultCount,
    required this.alertsEnabled,
    required this.lastCheckedAt,
  });

  final String id;
  final String term;
  final int resultCount;
  final bool alertsEnabled;
  final DateTime lastCheckedAt;

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    return SavedSearch(
      id: json['id'] as String,
      term: json['term'] as String,
      resultCount: json['result_count'] as int? ?? 0,
      alertsEnabled: json['alerts_enabled'] as bool? ?? true,
      lastCheckedAt: DateTime.parse(json['last_checked_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'term': term,
      'result_count': resultCount,
      'alerts_enabled': alertsEnabled,
      'last_checked_at': lastCheckedAt.toIso8601String(),
    };
  }

  SavedSearch copyWith({
    String? id,
    String? term,
    int? resultCount,
    bool? alertsEnabled,
    DateTime? lastCheckedAt,
  }) {
    return SavedSearch(
      id: id ?? this.id,
      term: term ?? this.term,
      resultCount: resultCount ?? this.resultCount,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, term, resultCount, alertsEnabled, lastCheckedAt];
}