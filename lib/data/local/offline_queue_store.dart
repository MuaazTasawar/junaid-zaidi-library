import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

enum QueuedActionType { renewCheckout, placeHold }

/// A single queued patron action, persisted so it survives app
/// restarts while offline. [payload] carries just enough to replay
/// the action once connectivity returns:
///   - renewCheckout: {'checkout_id': int}
///   - placeHold: {'patron_id': int, 'biblio_id': int}
class QueuedAction {
  const QueuedAction({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.label,
  });

  final String id;
  final QueuedActionType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  /// Human-readable summary for [OfflineScreen]'s queued-actions list
  /// (e.g. "Renew: Clean Code"). Optional — callers that don't have a
  /// title handy can omit it.
  final String? label;

  factory QueuedAction.fromJson(Map<String, dynamic> json) {
    return QueuedAction(
      id: json['id'] as String,
      type: QueuedActionType.values.firstWhere((t) => t.name == json['type']),
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      createdAt: DateTime.parse(json['created_at'] as String),
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'payload': payload,
      'created_at': createdAt.toIso8601String(),
      'label': label,
    };
  }
}

/// Hive-backed persistence for the offline action queue. Kept as a
/// thin storage layer — [OfflineCubit] owns the actual
/// enqueue/process business logic (Golden Rule #2 extended to
/// non-widget layers: storage classes stay dumb).
class OfflineQueueStore {
  const OfflineQueueStore();

  static const String _boxName = 'offlineQueueBox';
  static const String _queueKey = 'queuedActions';
  static const _uuid = Uuid();

  Future<List<QueuedAction>> loadAll() async {
    final Box box = await Hive.openBox(_boxName);
    final List<dynamic> raw = (box.get(_queueKey) as List?) ?? [];
    return raw
        .map((e) => QueuedAction.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _saveAll(List<QueuedAction> actions) async {
    final Box box = await Hive.openBox(_boxName);
    await box.put(_queueKey, actions.map((a) => a.toJson()).toList());
  }

  Future<QueuedAction> add({
    required QueuedActionType type,
    required Map<String, dynamic> payload,
    String? label,
  }) async {
    final QueuedAction action = QueuedAction(
      id: _uuid.v4(),
      type: type,
      payload: payload,
      createdAt: DateTime.now(),
      label: label,
    );

    final List<QueuedAction> all = await loadAll()..add(action);
    await _saveAll(all);
    return action;
  }

  Future<void> remove(String actionId) async {
    final List<QueuedAction> all = await loadAll()
      ..removeWhere((a) => a.id == actionId);
    await _saveAll(all);
  }

  Future<void> clear() async {
    final Box box = await Hive.openBox(_boxName);
    await box.delete(_queueKey);
  }
}