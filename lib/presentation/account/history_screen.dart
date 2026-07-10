import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../auth/auth_cubit.dart';
import '../common_widgets/book_cover.dart';
import '../common_widgets/empty_state.dart';
import '../common_widgets/error_state.dart';
import '../common_widgets/loading_skeleton.dart';
import '../common_widgets/status_badge.dart';
import 'account_cubit.dart';
import 'account_state.dart';

/// Screen 15: chronological (newest-first) borrowing history with a
/// local title/author filter. Export is a stated "coming soon"
/// action, not a real export — no repository method exists for it.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _filterController = TextEditingController();
  String _filter = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patron = context.read<AuthCubit>().state.patron;
      if (patron != null) sl<AccountCubit>().loadHistory(patron.patronId);
    });
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    final patron = context.watch<AuthCubit>().state.patron;

    return BlocProvider.value(
      value: sl<AccountCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Borrowing history'),
          actions: [
            IconButton(
              icon: const Icon(Icons.ios_share_rounded),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export coming soon')),
              ),
            ),
          ],
        ),
        body: BlocBuilder<AccountCubit, AccountState>(
          builder: (context, state) {
            if (state.historyStatus == SectionStatus.loading) {
              return LoadingSkeleton.list();
            }
            if (state.historyStatus == SectionStatus.error) {
              return ErrorState(
                message: state.historyErrorMessage,
                onRetry: () {
                  if (patron != null) context.read<AccountCubit>().loadHistory(patron.patronId);
                },
              );
            }
            if (state.history.isEmpty) {
              return const EmptyState(
                icon: Icons.history_rounded,
                title: 'No borrowing history yet',
              );
            }

            final filtered = _filter.isEmpty
                ? state.history
                : state.history
                .where((h) =>
            h.biblio.title.toLowerCase().contains(_filter.toLowerCase()) ||
                h.biblio.author.toLowerCase().contains(_filter.toLowerCase()))
                .toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _filterController,
                    onChanged: (v) => setState(() => _filter = v),
                    decoration: const InputDecoration(
                      hintText: 'Filter by title or author',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final view = filtered[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BookCover(
                              title: view.biblio.title,
                              author: view.biblio.author,
                              subject: view.biblio.subject,
                              width: 44, height: 62),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(view.biblio.title,
                                    style: AppTypography.lora(fontSize: 13, fontWeight: FontWeight.w600)),
                                Text(view.biblio.author,
                                    style: AppTypography.inter(fontSize: 11, color: ext.slate)),
                                const SizedBox(height: 4),
                                Text(
                                  'Out: ${DateFormatter.shortDate(view.checkout.issuedate)}  ·  '
                                      'Back: ${DateFormatter.shortDate(view.checkout.dueDate)}',
                                  style: AppTypography.mono(fontSize: 10, color: ext.slate),
                                ),
                                const SizedBox(height: 4),
                                const StatusBadge(label: 'Returned', kind: StatusBadgeKind.returned),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}