import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'notifications_cubit.dart';
import 'notifications_state.dart';

/// Screen 20: toggle list for notification preferences (due date
/// reminders with a days-before sub-option, hold-ready alerts,
/// overdue warnings, fine notices, new-arrival alerts for saved
/// searches and by subject). Persisted via
/// [NotificationsCubit.updatePrefs]; actually scheduling
/// `flutter_local_notifications` from these prefs is Phase 15.
class NotificationPrefsScreen extends StatelessWidget {
  const NotificationPrefsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<NotificationsCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Notification preferences')),
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            final prefs = state.prefs;
            final cubit = context.read<NotificationsCubit>();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Due date reminders'),
                  value: prefs.dueDateReminders,
                  onChanged: (v) => cubit.updatePrefs(prefs.copyWith(dueDateReminders: v)),
                ),
                if (prefs.dueDateReminders)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 12),
                    child: Row(
                      children: [1, 3, 7].map((days) {
                        final selected = prefs.daysBefore == days;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text('${days}d'),
                            selected: selected,
                            onSelected: (_) => cubit.updatePrefs(prefs.copyWith(daysBefore: days)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Hold ready alerts'),
                  value: prefs.holdReadyAlerts,
                  onChanged: (v) => cubit.updatePrefs(prefs.copyWith(holdReadyAlerts: v)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Overdue warnings'),
                  value: prefs.overdueWarnings,
                  onChanged: (v) => cubit.updatePrefs(prefs.copyWith(overdueWarnings: v)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fine notices'),
                  value: prefs.fineNotices,
                  onChanged: (v) => cubit.updatePrefs(prefs.copyWith(fineNotices: v)),
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('New arrivals for saved searches'),
                  value: prefs.savedSearchArrivals,
                  onChanged: (v) => cubit.updatePrefs(prefs.copyWith(savedSearchArrivals: v)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('New arrivals by subject'),
                  value: prefs.subjectArrivals,
                  onChanged: (v) => cubit.updatePrefs(prefs.copyWith(subjectArrivals: v)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}