import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/notification_item.dart';
import '../auth/auth_cubit.dart';
import '../common_widgets/empty_state.dart';
import '../common_widgets/error_state.dart';
import '../common_widgets/loading_skeleton.dart';
import 'notifications_cubit.dart';
import 'notifications_state.dart';

/// Screen 18: notification inbox — filter tabs (All / Unread /
/// Alerts), type-colored cards with unread dot, swipe-to-dismiss.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patron = context.read<AuthCubit>().state.patron;
      if (patron != null) sl<NotificationsCubit>().loadNotifications(patron.patronId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    final patron = context.watch<AuthCubit>().state.patron;

    return BlocProvider.value(
      value: sl<NotificationsCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            TextButton(
              onPressed: () => context.read<NotificationsCubit>().markAllRead(),
              child: const Text('Mark all read'),
            ),
          ],
        ),
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _FilterTab(
                        label: 'All',
                        selected: state.filter == NotificationFilter.all,
                        onTap: () => context.read<NotificationsCubit>().setFilter(NotificationFilter.all),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'Unread',
                        selected: state.filter == NotificationFilter.unread,
                        onTap: () => context.read<NotificationsCubit>().setFilter(NotificationFilter.unread),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'Alerts',
                        selected: state.filter == NotificationFilter.alerts,
                        onTap: () => context.read<NotificationsCubit>().setFilter(NotificationFilter.alerts),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.bookmark_border_rounded),
                        tooltip: 'Saved searches',
                        onPressed: () => context.push(AppRoutes.savedSearches),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune_rounded),
                        tooltip: 'Preferences',
                        onPressed: () => context.push(AppRoutes.notificationPrefs),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Builder(builder: (context) {
                    if (state.status == NotificationsStatus.loading) {
                      return LoadingSkeleton.list();
                    }
                    if (state.status == NotificationsStatus.error) {
                      return ErrorState(
                        message: state.errorMessage,
                        onRetry: () {
                          if (patron != null) {
                            context.read<NotificationsCubit>().loadNotifications(patron.patronId);
                          }
                        },
                      );
                    }
                    final visible = state.visibleNotifications;
                    if (visible.isEmpty) {
                      return const EmptyState(
                        icon: Icons.notifications_none_rounded,
                        title: "You're all caught up",
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: visible.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = visible[index];
                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: ext.stamp,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.close_rounded, color: Colors.white),
                          ),
                          onDismissed: (_) =>
                              context.read<NotificationsCubit>().dismissNotification(item.id),
                          child: _NotificationCard(item: item),
                        );
                      },
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? ext.primary.withOpacity(0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? ext.primary : ext.slate,
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});
  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    final IconData icon;
    final Color color;
    switch (item.type) {
      case NotificationType.overdue:
        icon = Icons.error_outline_rounded;
        color = ext.stamp;
      case NotificationType.holdReady:
        icon = Icons.check_circle_outline_rounded;
        color = ext.primary;
      case NotificationType.dueSoon:
        icon = Icons.schedule_rounded;
        color = ext.gold;
      case NotificationType.savedSearch:
        icon = Icons.auto_awesome_rounded;
        color = ext.primary;
      case NotificationType.checkoutConfirmed:
        icon = Icons.menu_book_rounded;
        color = ext.slate;
    }

    return Opacity(
      opacity: item.isRead ? 0.6 : 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ext.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ext.slate.withOpacity(0.15)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: AppTypography.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
                  const SizedBox(height: 2),
                  Text(item.body, style: AppTypography.inter(fontSize: 12, color: ext.slate)),
                ],
              ),
            ),
            if (!item.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: ext.primary, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}