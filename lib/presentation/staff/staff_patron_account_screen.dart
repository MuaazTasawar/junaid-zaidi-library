import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../common_widgets/app_button.dart';
import '../common_widgets/due_date_stamp.dart';
import '../common_widgets/loading_skeleton.dart';
import '../common_widgets/status_badge.dart';
import 'staff_cubit.dart';
import 'staff_state.dart';

/// Screen 32: staff view of a single patron's account — checkouts
/// (with force-renew), holds, fines (with per-fine pay), and an "Add
/// note" FAB (shows coming soon — no notes resource exists).
class StaffPatronAccountScreen extends StatefulWidget {
  const StaffPatronAccountScreen({super.key, required this.patronId});

  final int patronId;

  @override
  State<StaffPatronAccountScreen> createState() => _StaffPatronAccountScreenState();
}

class _StaffPatronAccountScreenState extends State<StaffPatronAccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<StaffCubit>().loadStaffPatronAccount(widget.patronId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return BlocProvider.value(
      value: sl<StaffCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Patron account')),
        floatingActionButton: FloatingActionButton(
          onPressed: () => ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Notes coming soon'))),
          child: const Icon(Icons.note_add_outlined),
        ),
        body: BlocBuilder<StaffCubit, StaffState>(
          builder: (context, state) {
            if (state.staffPatronAccountStatus == SectionStatus.loading || state.staffPatron == null) {
              return LoadingSkeleton.profile(context);
            }

            final patron = state.staffPatron!;
            final double fineBalance =
            state.staffPatronFines.fold(0, (sum, f) => sum + f.amountoutstanding);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(patron.fullName, style: AppTypography.lora(fontSize: 18, fontWeight: FontWeight.w600)),
                Text(patron.cardnumber, style: AppTypography.mono(fontSize: 13, color: ext.slate)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _Stat(label: 'Checkouts', value: '${state.staffPatronCheckouts.length}', ext: ext)),
                    const SizedBox(width: 8),
                    Expanded(child: _Stat(label: 'Holds', value: '${state.staffPatronHolds.length}', ext: ext)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Stat(
                        label: 'Fines',
                        value: 'PKR ${fineBalance.toStringAsFixed(0)}',
                        ext: ext,
                        tint: fineBalance > 0 ? ext.stamp : ext.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Active checkouts', style: AppTypography.lora(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                if (state.staffPatronCheckouts.isEmpty)
                  Text('None', style: AppTypography.inter(fontSize: 12, color: ext.slate))
                else
                  ...state.staffPatronCheckouts.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Checkout #${c.checkoutId}',
                                  style: AppTypography.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                              if (c.isOverdue)
                                Text('Overdue', style: AppTypography.inter(fontSize: 11, color: ext.stamp)),
                            ],
                          ),
                        ),
                        DueDateStamp(dueDate: c.dueDate),
                        const SizedBox(width: 8),
                        AppButton(
                          label: 'Force renew',
                          fullWidth: false,
                          variant: AppButtonVariant.outlined,
                          isLoading: state.forceRenewingCheckoutId == c.checkoutId,
                          onPressed: () => context.read<StaffCubit>().forceRenew(c.checkoutId, patron.patronId),
                        ),
                      ],
                    ),
                  )),
                const SizedBox(height: 20),
                Text('Active holds', style: AppTypography.lora(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                if (state.staffPatronHolds.isEmpty)
                  Text('None', style: AppTypography.inter(fontSize: 12, color: ext.slate))
                else
                  ...state.staffPatronHolds.map((h) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: StatusBadge(
                      label: h.isReadyForPickup ? 'Ready for pickup' : '#${h.priority} in queue',
                      kind: h.isReadyForPickup ? StatusBadgeKind.ready : StatusBadgeKind.inQueue,
                    ),
                  )),
                const SizedBox(height: 20),
                Text('Outstanding fines', style: AppTypography.lora(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                if (state.staffPatronFines.where((f) => !f.isPaid).isEmpty)
                  Text('None', style: AppTypography.inter(fontSize: 12, color: ext.slate))
                else
                  ...state.staffPatronFines.where((f) => !f.isPaid).map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(child: Text(f.description, style: AppTypography.inter(fontSize: 12))),
                        Text('PKR ${f.amount.toStringAsFixed(0)}', style: AppTypography.mono(fontSize: 12, fontWeight: FontWeight.w600)),
                        TextButton(
                          onPressed: () => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text('Payment integration coming soon'))),
                          child: const Text('Pay'),
                        ),
                      ],
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

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.ext, this.tint});
  final String label;
  final String value;
  final AppColorExtension ext;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final color = tint ?? ext.primary;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(value, style: AppTypography.mono(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          Text(label, style: AppTypography.inter(fontSize: 10, color: ext.slate)),
        ],
      ),
    );
  }
}