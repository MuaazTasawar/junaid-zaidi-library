import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../auth/auth_cubit.dart';
import 'staff_cubit.dart';
import 'staff_state.dart';

/// Screen 28: staff dashboard — 4 large action cards (scan
/// checkout/checkin, search patron/item) and a recent-activity feed
/// (session-only, see Phase 14 note).
class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    final patron = context.watch<AuthCubit>().state.patron;

    return BlocProvider.value(
      value: sl<StaffCubit>(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ext.primary,
          foregroundColor: Colors.white,
          title: Text('LibConnect Staff', style: AppTypography.lora(fontSize: 18, color: Colors.white)),
          actions: [
            if (patron != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Library Staff',
                        style: AppTypography.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ),
          ],
        ),
        body: BlocBuilder<StaffCubit, StaffState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.15,
                  children: [
                    _ActionCard(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'Scan Check Out',
                      tint: ext.primary,
                      onTap: () => context.push(AppRoutes.staffScanCheckout),
                    ),
                    _ActionCard(
                      icon: Icons.settings_backup_restore_rounded,
                      label: 'Scan Check In',
                      tint: ext.slate,
                      onTap: () => context.push(AppRoutes.staffScanCheckin),
                    ),
                    _ActionCard(
                      icon: Icons.person_search_rounded,
                      label: 'Search Patron',
                      tint: ext.slate,
                      onTap: () => context.push(AppRoutes.staffPatronSearch),
                    ),
                    _ActionCard(
                      icon: Icons.menu_book_rounded,
                      label: 'Search Item',
                      tint: ext.slate,
                      onTap: () => context.push(AppRoutes.staffItemSearch),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text('Recent activity',
                    style: AppTypography.lora(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                if (state.recentActivity.isEmpty)
                  Text('No activity yet this session',
                      style: AppTypography.inter(fontSize: 12, color: ext.slate))
                else
                  ...state.recentActivity.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Icon(
                          a.isCheckout ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                          size: 16,
                          color: a.isCheckout ? ext.primary : ext.slate,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${a.patronName} · ${a.bookTitle}',
                                  style: AppTypography.inter(fontSize: 12, fontWeight: FontWeight.w600),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(a.isCheckout ? 'Checked out' : 'Checked in',
                                  style: AppTypography.inter(fontSize: 11, color: ext.slate)),
                            ],
                          ),
                        ),
                        Text(DateFormatter.shortDate(a.timestamp),
                            style: AppTypography.mono(fontSize: 10, color: ext.slate)),
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

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.label, required this.tint, required this.onTap});
  final IconData icon;
  final String label;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tint.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: tint, size: 30),
              const SizedBox(height: 10),
              Text(label,
                  textAlign: TextAlign.center,
                  style: AppTypography.inter(fontSize: 13, fontWeight: FontWeight.w600, color: tint)),
            ],
          ),
        ),
      ),
    );
  }
}