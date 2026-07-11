import 'package:equatable/equatable.dart';

import '../../data/local/offline_queue_store.dart';

enum ConnectivityStatus { unknown, online, offline }

class OfflineState extends Equatable {
  const OfflineState({
    this.connectivityStatus = ConnectivityStatus.unknown,
    this.queuedActions = const [],
    this.isProcessingQueue = false,
    this.lastSyncError,
  });

  final ConnectivityStatus connectivityStatus;
  final List<QueuedAction> queuedActions;
  final bool isProcessingQueue;
  final String? lastSyncError;

  bool get isOffline => connectivityStatus == ConnectivityStatus.offline;

  OfflineState copyWith({
    ConnectivityStatus? connectivityStatus,
    List<QueuedAction>? queuedActions,
    bool? isProcessingQueue,
    String? lastSyncError,
    bool clearSyncError = false,
  }) {
    return OfflineState(
      connectivityStatus: connectivityStatus ?? this.connectivityStatus,
      queuedActions: queuedActions ?? this.queuedActions,
      isProcessingQueue: isProcessingQueue ?? this.isProcessingQueue,
      lastSyncError: clearSyncError ? null : (lastSyncError ?? this.lastSyncError),
    );
  }

  @override
  List<Object?> get props =>
      [connectivityStatus, queuedActions, isProcessingQueue, lastSyncError];
}