import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../auth/auth_cubit.dart';
import '../common_widgets/app_button.dart';
import '../common_widgets/book_cover.dart';
import '../common_widgets/due_date_stamp.dart';
import '../common_widgets/empty_state.dart';
import '../common_widgets/error_state.dart';
import '../common_widgets/loading_skeleton.dart';
import 'account_cubit.dart';
import 'account_state.dart';
import 'renew_confirm_sheet.dart';

/// Screen 12: active checkouts, sorted overdue → due-soon → safe
/// (done in [AccountCubit]), each with a renew action, plus a pinned
/// outstanding-fines summary bar at the bottom.
class CheckoutsScreen extends StatefulWidget {
  const CheckoutsScreen({super.key});

  @override
  State<CheckoutsScreen> createState() => _CheckoutsScreenState();
}

class _CheckoutsScreenState extends State<CheckoutsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patron = context.read<AuthCubit>().state.patron;
      if (patron != null) sl<AccountCubit>().loadCheckouts(patron.patronId);
    });
  }

  void _openRenewSheet(BuildContext context, CheckoutView view) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: sl<AccountCubit>(),
        child: RenewConfirmSheet(view: view),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    final patron = context.watch<AuthCubit>().state.patron;

    return BlocProvider.value(
      value: sl<AccountCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<AccountCubit, AccountState>(
            builder: (context, state) =>
                Text('My checkouts (${state.checkouts.length})'),
          ),
        ),
        body: BlocBuilder<AccountCubit, AccountState>(
          builder: (context, state) {
            if (state.checkoutsStatus == SectionStatus.loading) {
              return LoadingSkeleton.cards();
            }
            if (state.checkoutsStatus == SectionStatus.error) {
              return ErrorState(
                message: state.checkoutsErrorMessage,
                onRetry: () {
                  if (patron != null) context.read<AccountCubit>().loadCheckouts(patron.patronId);
                },
              );
            }
            if (state.checkouts.isEmpty) {
              return const EmptyState(
                icon: Icons.menu_book_outlined,
                title: 'You have no active checkouts',
                message: 'Browse the catalog to check something out.',
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.checkouts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final view = state.checkouts[index];
                      final isOverdue = view.checkout.isOverdue;
                      final isDueSoon = view.checkout.isDueSoon;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isOverdue
                                ? ext.stamp
                                : (isDueSoon ? ext.gold : ext.slate.withOpacity(0.2)),
                            width: isOverdue || isDueSoon ? 1.4 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BookCover(
                              title: view.biblio.title,
                              author: view.biblio.author,
                              subject: view.biblio.subject,
                              width: 48,
                              height: 68,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(view.biblio.title,
                                      style: AppTypography.lora(fontSize: 13, fontWeight: FontWeight.w600),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  Text(view.biblio.author,
                                      style: AppTypography.inter(fontSize: 11, color: ext.slate)),
                                  const SizedBox(height: 6),
                                  Text(
                                    isOverdue ? 'Overdue' : (isDueSoon ? 'Due soon' : 'Safe'),
                                    style: AppTypography.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isOverdue ? ext.stamp : (isDueSoon ? ext.gold : ext.slate),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AppButton(
                                    label: 'Renew',
                                    fullWidth: false,
                                    variant: AppButtonVariant.outlined,
                                    isLoading: state.renewingCheckoutId == view.checkout.checkoutId,
                                    onPressed: () => _openRenewSheet(context, view),
                                  ),
                                ],
                              ),
                            ),
                            DueDateStamp(dueDate: view.checkout.dueDate),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (state.outstandingBalance > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: ext.inkText,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Outstanding balance',
                                  style: AppTypography.inter(fontSize: 11, color: ext.background.withOpacity(0.7))),
                              Text(
                                'PKR ${state.outstandingBalance.toStringAsFixed(0)}',
                                style: AppTypography.mono(
                                    fontSize: 22, fontWeight: FontWeight.w600, color: ext.background),
                              ),
                            ],
                          ),
                        ),
                        AppButton(
                          label: 'Pay Now',
                          fullWidth: false,
                          variant: AppButtonVariant.destructive,
                          onPressed: () => context.push(AppRoutes.fines),
                        ),
                      ],
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