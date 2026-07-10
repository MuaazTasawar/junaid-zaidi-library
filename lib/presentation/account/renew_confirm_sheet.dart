import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../auth/auth_cubit.dart';
import '../common_widgets/app_button.dart';
import '../common_widgets/book_cover.dart';
import '../common_widgets/due_date_stamp.dart';
import 'account_cubit.dart';
import 'account_state.dart';

const int _kMaxRenewals = 3;

/// Screen 13: DraggableScrollableSheet confirming a single checkout
/// renewal — shows the new due date as an ink-colored [DueDateStamp]
/// preview, renewals-remaining count, and an error branch if the
/// renewal limit is already reached.
class RenewConfirmSheet extends StatelessWidget {
  const RenewConfirmSheet({super.key, required this.view});

  final CheckoutView view;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.35,
      maxChildSize: 0.75,
      expand: false,
      builder: (context, scrollController) {
        final ext = Theme.of(context).extension<AppColorExtension>()!;
        final int remaining = _kMaxRenewals - view.checkout.renewalsCount;
        final DateTime newDueDate = view.checkout.dueDate.add(const Duration(days: 14));

        return Container(
          decoration: BoxDecoration(
            color: ext.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: BlocBuilder<AccountCubit, AccountState>(
            builder: (context, state) {
              final patron = context.watch<AuthCubit>().state.patron;

              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ext.slate.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      BookCover(
                        title: view.biblio.title,
                        author: view.biblio.author,
                        subject: view.biblio.subject,
                        width: 56,
                        height: 78,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(view.biblio.title,
                            style: AppTypography.lora(fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (remaining <= 0) ...[
                    Text(
                      'Renewal limit reached',
                      style: AppTypography.inter(
                          fontSize: 14, fontWeight: FontWeight.w600, color: ext.stamp),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'This item has reached its renewal limit. Please return it to the library.',
                      style: AppTypography.inter(fontSize: 13, color: ext.slate),
                    ),
                  ] else ...[
                    Text('New due date', style: AppTypography.inter(fontSize: 12, color: ext.slate)),
                    const SizedBox(height: 8),
                    DueDateStamp(dueDate: newDueDate),
                    const SizedBox(height: 16),
                    Text(
                      '$remaining ${remaining == 1 ? 'renewal' : 'renewals'} remaining',
                      style: AppTypography.inter(fontSize: 12, color: ext.slate),
                    ),
                    if (state.renewError != null) ...[
                      const SizedBox(height: 12),
                      Text(state.renewError!,
                          style: AppTypography.inter(fontSize: 12, color: ext.stamp)),
                    ],
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Confirm renewal',
                      isLoading: state.renewingCheckoutId == view.checkout.checkoutId,
                      onPressed: patron == null
                          ? null
                          : () => context
                          .read<AccountCubit>()
                          .renewCheckout(view.checkout.checkoutId, patron.patronId),
                    ),
                  ],
                  const SizedBox(height: 8),
                  AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.text,
                    onPressed: () => context.pop(),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}