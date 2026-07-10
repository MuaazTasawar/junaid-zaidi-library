import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../auth/auth_cubit.dart';
import '../common_widgets/book_cover.dart';
import '../common_widgets/empty_state.dart';
import '../common_widgets/error_state.dart';
import '../common_widgets/loading_skeleton.dart';
import '../common_widgets/status_badge.dart';
import 'account_cubit.dart';
import 'account_state.dart';

/// Screen 14: two sections — "Ready for pickup" and "In queue" —
/// with swipe-to-cancel on queued holds.
class HoldsScreen extends StatefulWidget {
  const HoldsScreen({super.key});

  @override
  State<HoldsScreen> createState() => _HoldsScreenState();
}

class _HoldsScreenState extends State<HoldsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patron = context.read<AuthCubit>().state.patron;
      if (patron != null) sl<AccountCubit>().loadHolds(patron.patronId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    final patron = context.watch<AuthCubit>().state.patron;

    return BlocProvider.value(
      value: sl<AccountCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('My holds')),
        body: BlocBuilder<AccountCubit, AccountState>(
          builder: (context, state) {
            if (state.holdsStatus == SectionStatus.loading) {
              return LoadingSkeleton.cards();
            }
            if (state.holdsStatus == SectionStatus.error) {
              return ErrorState(
                message: state.holdsErrorMessage,
                onRetry: () {
                  if (patron != null) context.read<AccountCubit>().loadHolds(patron.patronId);
                },
              );
            }
            if (state.holds.isEmpty) {
              return const EmptyState(
                icon: Icons.bookmark_border_rounded,
                title: 'No holds placed',
                message: 'Place a hold from any book detail page.',
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Ready for pickup',
                    style: AppTypography.inter(
                        fontSize: 12, fontWeight: FontWeight.w600, color: ext.primary)),
                const SizedBox(height: 10),
                if (state.readyForPickup.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text('Nothing ready yet',
                        style: AppTypography.inter(fontSize: 12, color: ext.slate)),
                  )
                else
                  ...state.readyForPickup.map((h) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReadyHoldCard(view: h),
                  )),
                const SizedBox(height: 16),
                Text('In queue',
                    style: AppTypography.inter(
                        fontSize: 12, fontWeight: FontWeight.w600, color: ext.slate)),
                const SizedBox(height: 10),
                if (state.inQueue.isEmpty)
                  Text('No holds in queue',
                      style: AppTypography.inter(fontSize: 12, color: ext.slate))
                else
                  ...state.inQueue.map((h) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: ValueKey('hold-${h.hold.holdId}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: ext.stamp,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        if (patron != null) {
                          context.read<AccountCubit>().cancelHold(h.hold.holdId, patron.patronId);
                        }
                      },
                      child: _QueuedHoldCard(view: h),
                    ),
                  )),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReadyHoldCard extends StatelessWidget {
  const _ReadyHoldCard({required this.view});
  final HoldView view;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: ext.primary.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          BookCover(
              title: view.biblio.title, author: view.biblio.author, subject: view.biblio.subject,
              width: 44, height: 62),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(view.biblio.title,
                    style: AppTypography.lora(fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                const StatusBadge(label: 'Ready!', kind: StatusBadgeKind.ready),
                const SizedBox(height: 4),
                Text('COMSATS Main Library',
                    style: AppTypography.inter(fontSize: 11, color: ext.slate)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QueuedHoldCard extends StatelessWidget {
  const _QueuedHoldCard({required this.view});
  final HoldView view;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: ext.slate.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          BookCover(
              title: view.biblio.title, author: view.biblio.author, subject: view.biblio.subject,
              width: 44, height: 62),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(view.biblio.title,
                    style: AppTypography.lora(fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                StatusBadge(label: '#${view.hold.priority} in queue', kind: StatusBadgeKind.inQueue),
                const SizedBox(height: 4),
                Text('Est. wait ~${view.hold.priority * 10} days',
                    style: AppTypography.inter(fontSize: 11, color: ext.slate)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}