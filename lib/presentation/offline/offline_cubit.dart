import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/local/offline_queue_store.dart';
import '../../data/repositories/library_repository.dart';
import 'offline_state.dart';

/// App-wide connectivity + offline-action-queue manager. Registered
/// as a singleton (see Phase 13 di update) so [OfflineBanner] can be
/// shown from a single global listener in `app.dart` rather than
/// re-subscribing to connectivity per screen.
class OfflineCubit extends Cubit<OfflineState> {
  OfflineCubit(this._repository, this._store) : super(const OfflineState()) {
    _init();
  }

  final LibraryRepository _repository;
  final OfflineQueueStore _store;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> _init() async {
    final List<QueuedAction> queued = await _store.loadAll();
    emit(state.copyWith(queuedActions: queued));

    final List<ConnectivityResult> initial = await _connectivity.checkConnectivity();
    _applyConnectivity(initial);

    _subscription = _connectivity.onConnectivityChanged.listen(_applyConnectivity);
  }

  void _applyConnectivity(List<ConnectivityResult> results) {
    final bool online = results.any((r) => r != ConnectivityResult.none);
    final ConnectivityStatus newStatus =
    online ? ConnectivityStatus.online : ConnectivityStatus.offline;

    final bool justCameOnline =
        newStatus == ConnectivityStatus.online && state.connectivityStatus == ConnectivityStatus.offline;

    emit(state.copyWith(connectivityStatus: newStatus));

    if (justCameOnline && state.queuedActions.isNotEmpty) {
      processQueue();
    }
  }

  Future<void> retryConnection() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    _applyConnectivity(results);
  }

  /// Adds an action to the offline queue for later replay. See the
  /// Phase 13 scope note: nothing currently calls this automatically
  /// on a failed renew/hold — it's available for a future
  /// connectivity-aware repository wrapper to call directly.
  Future<void> enqueueAction({
    required QueuedActionType type,
    required Map<String, dynamic> payload,
    String? label,
  }) async {
    await _store.add(type: type, payload: payload, label: label);
    emit(state.copyWith(queuedActions: await _store.loadAll()));
  }

  Future<void> processQueue() async {
    if (state.queuedActions.isEmpty || state.isProcessingQueue) return;

    emit(state.copyWith(isProcessingQueue: true, clearSyncError: true));

    for (final QueuedAction action in List.of(state.queuedActions)) {
      try {
        switch (action.type) {
          case QueuedActionType.renewCheckout:
            await _repository.renewCheckout(action.payload['checkout_id'] as int);
          case QueuedActionType.placeHold:
            await _repository.placeHold(
              patronId: action.payload['patron_id'] as int,
              biblioId: action.payload['biblio_id'] as int,
            );
        }
        await _store.remove(action.id);
      } on LibraryException catch (e) {
        // Leave in queue if it's a genuine business-rule failure that
        // might still resolve (e.g. transient); surface the most
        // recent error for visibility on OfflineScreen.
        emit(state.copyWith(lastSyncError: e.message));
      }
    }

    emit(state.copyWith(
      queuedActions: await _store.loadAll(),
      isProcessingQueue: false,
    ));
  }

  Future<void> removeQueuedAction(String actionId) async {
    await _store.remove(actionId);
    emit(state.copyWith(queuedActions: await _store.loadAll()));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}