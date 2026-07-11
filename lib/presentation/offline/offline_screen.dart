import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/local/offline_queue_store.dart';
import '../common_widgets/app_button.dart';
import 'offline_cubit.dart';
import 'offline_state.dart';

/// Screen 24 (full-screen variant): shown when the app is fully
/// offline at launch — wifi-off icon, queued-action count, list of
/// queued actions, and a "Retry connection" button.
///
/// The persistent top-strip variant ([OfflineBanner], built in
/// Phase 2) is rendered globally from `app.dart` on every other
/// screen; this full screen is the dedicated offline landing state.
class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<OfflineCubit, OfflineState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 56, color: ext.slate),
                  const SizedBox(height: 20),
                  Text("You're offline",
                      style: AppTypography.lora(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    state.queuedActions.isEmpty
                        ? 'Reconnect to continue using LibConnect.'
                        : '${state.queuedActions.length} ${state.queuedActions.length == 1 ? 'action' : 'actions'} queued and will sync when reconnected.',
                    textAlign: TextAlign.center,
                    style: AppTypography.inter(fontSize: 13, color: ext.slate),
                  ),
                  if (state.queuedActions.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    ...state.queuedActions.map((a) => _QueuedActionTile(action: a)),
                  ],
                  const SizedBox(height: 28),
                  AppButton(
                    label: 'Retry connection',
                    variant: AppButtonVariant.outlined,
                    fullWidth: false,
                    isLoading: state.isProcessingQueue,
                    onPressed: () => context.read<OfflineCubit>().retryConnection(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QueuedActionTile extends StatelessWidget {
  const _QueuedActionTile({required this.action});
  final QueuedAction action;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    final String label = action.label ??
        (action.type == QueuedActionType.renewCheckout ? 'Renew item' : 'Place hold');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: ext.slate.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            action.type == QueuedActionType.renewCheckout
                ? Icons.refresh_rounded
                : Icons.bookmark_border_rounded,
            size: 18,
            color: ext.slate,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: AppTypography.inter(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}