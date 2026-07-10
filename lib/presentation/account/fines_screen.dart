import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../auth/auth_cubit.dart';
import '../common_widgets/app_button.dart';
import '../common_widgets/error_state.dart';
import '../common_widgets/loading_skeleton.dart';
import 'account_cubit.dart';
import 'account_state.dart';

/// Screen 16: dark balance header, itemized outstanding fine list
/// with per-item Pay, collapsible paid-fines section, and a
/// zero-fines success state.
class FinesScreen extends StatefulWidget {
  const FinesScreen({super.key});

  @override
  State<FinesScreen> createState() => _FinesScreenState();
}

class _FinesScreenState extends State<FinesScreen> {
  bool _paidExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patron = context.read<AuthCubit>().state.patron;
      if (patron != null) sl<AccountCubit>().loadFines(patron.patronId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    final patron = context.watch<AuthCubit>().state.patron;

    return BlocProvider.value(
      value: sl<AccountCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Fines & payments')),
        body: BlocBuilder<AccountCubit, AccountState>(
          builder: (context, state) {
            if (state.finesStatus == SectionStatus.loading) {
              return LoadingSkeleton.cards();
            }
            if (state.finesStatus == SectionStatus.error) {
              return ErrorState(
                message: state.finesErrorMessage,
                onRetry: () {
                  if (patron != null) context.read<AccountCubit>().loadFines(patron.patronId);
                },
              );
            }

            final outstanding = state.fines.where((f) => !f.isPaid).toList();
            final paid = state.fines.where((f) => f.isPaid).toList();

            if (outstanding.isEmpty && paid.isEmpty) {
              return _ZeroFinesState(ext: ext);
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (outstanding.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: ext.inkText,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Outstanding balance',
                            style: AppTypography.inter(fontSize: 12, color: ext.background.withOpacity(0.7))),
                        const SizedBox(height: 6),
                        Text('PKR ${state.outstandingBalance.toStringAsFixed(0)}',
                            style: AppTypography.mono(fontSize: 28, fontWeight: FontWeight.w600, color: ext.background)),
                        const SizedBox(height: 14),
                        AppButton(
                          label: 'Pay all',
                          variant: AppButtonVariant.destructive,
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Payment integration coming soon')),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...outstanding.map((f) => _FineTile(fine: f, showPay: true)),
                ] else
                  _ZeroFinesState(ext: ext),
                if (paid.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () => setState(() => _paidExpanded = !_paidExpanded),
                    child: Row(
                      children: [
                        Text('Paid fines',
                            style: AppTypography.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Icon(_paidExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                      ],
                    ),
                  ),
                  if (_paidExpanded) ...paid.map((f) => _FineTile(fine: f, showPay: false)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ZeroFinesState extends StatelessWidget {
  const _ZeroFinesState({required this.ext});
  final AppColorExtension ext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.check_circle_rounded, size: 48, color: ext.primary),
          const SizedBox(height: 12),
          Text('You have no outstanding fines',
              style: AppTypography.lora(fontSize: 15, fontWeight: FontWeight.w600, color: ext.primary)),
        ],
      ),
    );
  }
}

class _FineTile extends StatelessWidget {
  const _FineTile({required this.fine, required this.showPay});
  final dynamic fine;
  final bool showPay;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fine.description, style: AppTypography.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${fine.debitTypeCode} · ${fine.date.toString().split(' ').first}',
                    style: AppTypography.inter(fontSize: 11, color: ext.slate)),
              ],
            ),
          ),
          Text('PKR ${fine.amount.toStringAsFixed(0)}',
              style: AppTypography.mono(fontSize: 13, fontWeight: FontWeight.w600)),
          if (showPay) ...[
            const SizedBox(width: 10),
            TextButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment integration coming soon')),
              ),
              child: const Text('Pay'),
            ),
          ],
        ],
      ),
    );
  }
}