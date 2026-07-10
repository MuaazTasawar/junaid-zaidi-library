import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../auth/auth_cubit.dart';
import 'account_cubit.dart';
import 'account_state.dart';

/// Screen 11: account overview — 3 stat cards (checkouts / holds /
/// fines) and 4 menu entries into the sub-screens, plus a library
/// card preview shortcut.
class AccountHomeScreen extends StatefulWidget {
  const AccountHomeScreen({super.key});

  @override
  State<AccountHomeScreen> createState() => _AccountHomeScreenState();
}

class _AccountHomeScreenState extends State<AccountHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patron = context.read<AuthCubit>().state.patron;
      if (patron != null) {
        sl<AccountCubit>().loadOverview(patron.patronId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return BlocProvider.value(
      value: sl<AccountCubit>(),
      child: Scaffold(
        appBar: AppBar(title: Text('My account', style: AppTypography.lora(fontSize: 18))),
        body: BlocBuilder<AccountCubit, AccountState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Checkouts',
                        value: '${state.checkouts.length}',
                        tint: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: 'Holds',
                        value: '${state.holds.length}',
                        tint: ext.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: 'Fines',
                        value: 'PKR ${state.outstandingBalance.toStringAsFixed(0)}',
                        tint: state.outstandingBalance > 0 ? ext.stamp : ext.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _MenuTile(
                  icon: Icons.menu_book_outlined,
                  label: 'My checkouts',
                  onTap: () => context.push(AppRoutes.checkouts),
                ),
                _MenuTile(
                  icon: Icons.bookmark_border_rounded,
                  label: 'My holds',
                  onTap: () => context.push(AppRoutes.holds),
                ),
                _MenuTile(
                  icon: Icons.history_rounded,
                  label: 'Borrowing history',
                  onTap: () => context.push(AppRoutes.history),
                ),
                _MenuTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'Fines & payments',
                  onTap: () => context.push(AppRoutes.fines),
                ),
                const SizedBox(height: 20),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push(AppRoutes.libraryCard),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: ext.primary, width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.badge_outlined, color: ext.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('View library card',
                              style: AppTypography.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                        Icon(Icons.chevron_right_rounded, color: ext.slate),
                      ],
                    ),
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.tint});
  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: tint.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(value,
              style: AppTypography.mono(fontSize: 16, fontWeight: FontWeight.w600, color: tint)),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.inter(fontSize: 11, color: ext.slate)),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: ext.inkText),
      title: Text(label, style: AppTypography.inter(fontSize: 14)),
      trailing: Icon(Icons.chevron_right_rounded, color: ext.slate),
      onTap: onTap,
    );
  }
}