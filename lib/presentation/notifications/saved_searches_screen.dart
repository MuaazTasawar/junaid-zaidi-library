import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../common_widgets/app_button.dart';
import '../common_widgets/empty_state.dart';
import 'notifications_cubit.dart';
import 'notifications_state.dart';

/// Screen 19: saved search list with per-search alert toggle, last
/// checked timestamp, swipe-to-delete, and a FAB dialog to add a new
/// saved search.
class SavedSearchesScreen extends StatefulWidget {
  const SavedSearchesScreen({super.key});

  @override
  State<SavedSearchesScreen> createState() => _SavedSearchesScreenState();
}

class _SavedSearchesScreenState extends State<SavedSearchesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<NotificationsCubit>().loadSavedSearches();
    });
  }

  void _openAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Save a search'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Data Structures'),
        ),
        actions: [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.text,
            fullWidth: false,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          AppButton(
            label: 'Save',
            fullWidth: false,
            onPressed: () {
              context.read<NotificationsCubit>().addSavedSearch(controller.text);
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return BlocProvider.value(
      value: sl<NotificationsCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Saved searches')),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openAddDialog(context),
          child: const Icon(Icons.add_rounded),
        ),
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state.savedSearches.isEmpty) {
              return const EmptyState(
                icon: Icons.bookmark_border_rounded,
                title: 'No saved searches yet',
                message: 'Save a search to get alerts.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.savedSearches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final search = state.savedSearches[index];
                return Dismissible(
                  key: ValueKey('saved-search-${search.id}'),
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
                  onDismissed: (_) =>
                      context.read<NotificationsCubit>().deleteSavedSearch(search.id),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ext.surface,
                      border: Border.all(color: ext.slate.withOpacity(0.15)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(search.term,
                                      style: AppTypography.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: ext.primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text('${search.resultCount}',
                                        style: AppTypography.mono(fontSize: 11, color: ext.primary)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Checked ${DateFormatter.shortDate(search.lastCheckedAt)}',
                                style: AppTypography.mono(fontSize: 10, color: ext.slate),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: search.alertsEnabled,
                          onChanged: (_) =>
                              context.read<NotificationsCubit>().toggleSavedSearchAlerts(search.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}