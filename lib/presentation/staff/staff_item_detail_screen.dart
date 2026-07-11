import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../common_widgets/app_button.dart';
import '../common_widgets/book_cover.dart';
import '../common_widgets/due_date_stamp.dart';
import '../common_widgets/empty_state.dart';
import '../common_widgets/loading_skeleton.dart';
import '../common_widgets/status_badge.dart';
import 'staff_cubit.dart';
import 'staff_state.dart';

/// Screen 34: full staff item detail — hero cover, metadata, status,
/// current checkout (if any), shelf location, barcode, and a
/// checkout-history section that's honestly limited to the item's
/// current active checkout (see Phase 14 note — no per-item history
/// endpoint exists).
class StaffItemDetailScreen extends StatefulWidget {
  const StaffItemDetailScreen({super.key, required this.itemId});

  final int itemId;

  @override
  State<StaffItemDetailScreen> createState() => _StaffItemDetailScreenState();
}

class _StaffItemDetailScreenState extends State<StaffItemDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<StaffCubit>().loadItemDetail(widget.itemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return BlocProvider.value(
      value: sl<StaffCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Item detail')),
        body: BlocBuilder<StaffCubit, StaffState>(
          builder: (context, state) {
            if (state.itemDetailStatus == SectionStatus.loading || state.detailItem == null) {
              return LoadingSkeleton.cards();
            }

            final item = state.detailItem!;
            final biblio = state.detailBiblio!;
            final checkout = state.detailCurrentCheckout;
            final patron = state.detailCurrentPatron;

            final StatusBadgeKind kind;
            final String label;
            if (item.notforloan == 4) {
              kind = StatusBadgeKind.lost;
              label = 'Lost';
            } else if (item.isAvailable) {
              kind = StatusBadgeKind.available;
              label = 'Available';
            } else {
              kind = StatusBadgeKind.onLoan;
              label = 'On loan';
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: BookCover(title: biblio.title, author: biblio.author, subject: biblio.subject, width: 200, height: 100),
                ),
                const SizedBox(height: 16),
                Text(biblio.title, style: AppTypography.lora(fontSize: 18, fontWeight: FontWeight.w600)),
                Text(biblio.author, style: AppTypography.inter(fontSize: 13, color: ext.slate)),
                Text('ISBN ${biblio.isbn}', style: AppTypography.mono(fontSize: 12, color: ext.slate)),
                Text(item.itemcallnumber, style: AppTypography.mono(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                StatusBadge(label: label, kind: kind),
                if (checkout != null && patron != null) ...[
                  const SizedBox(height: 16),
                  Text('Checked out to: ${patron.fullName}', style: AppTypography.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DueDateStamp(dueDate: checkout.dueDate),
                  if (checkout.isOverdue) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${DateTime.now().difference(checkout.dueDate).inDays} days overdue',
                      style: AppTypography.inter(fontSize: 12, color: ext.stamp, fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
                const SizedBox(height: 16),
                Text('Shelf location', style: AppTypography.inter(fontSize: 11, color: ext.slate)),
                Text(item.location, style: AppTypography.inter(fontSize: 13)),
                const SizedBox(height: 8),
                Text('Barcode', style: AppTypography.inter(fontSize: 11, color: ext.slate)),
                Text('${item.itemnumber}', style: AppTypography.mono(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),
                Text('Checkout history', style: AppTypography.lora(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                if (checkout == null)
                  const EmptyState(icon: Icons.history_rounded, title: 'No current checkout on record')
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(border: Border.all(color: ext.slate.withOpacity(0.15)), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(patron?.fullName ?? 'Unknown', style: AppTypography.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                              Text('Out: ${DateFormatter.shortDate(checkout.issuedate)}', style: AppTypography.mono(fontSize: 11, color: ext.slate)),
                            ],
                          ),
                        ),
                        const StatusBadge(label: 'Active', kind: StatusBadgeKind.onLoan),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Edit item',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Editing coming soon'))),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}