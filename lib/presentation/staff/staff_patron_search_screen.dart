import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../common_widgets/empty_state.dart';
import '../common_widgets/loading_skeleton.dart';
import 'staff_cubit.dart';
import 'staff_state.dart';

/// Screen 31: staff patron search — searches name, card number, and
/// email; each result shows active checkouts count and fine balance.
class StaffPatronSearchScreen extends StatefulWidget {
  const StaffPatronSearchScreen({super.key});

  @override
  State<StaffPatronSearchScreen> createState() => _StaffPatronSearchScreenState();
}

class _StaffPatronSearchScreenState extends State<StaffPatronSearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return BlocProvider.value(
      value: sl<StaffCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Search patron')),
        body: BlocBuilder<StaffCubit, StaffState>(
          builder: (context, state) {
            final cubit = context.read<StaffCubit>();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    onSubmitted: cubit.searchPatrons,
                    decoration: InputDecoration(
                      hintText: 'Name, card number, or email',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward_rounded),
                        onPressed: () => cubit.searchPatrons(_controller.text),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Builder(builder: (context) {
                    if (state.patronSearchStatus == SectionStatus.loading) {
                      return LoadingSkeleton.list();
                    }
                    if (state.patronSearchStatus == SectionStatus.idle) {
                      return const EmptyState(
                        icon: Icons.person_search_rounded,
                        title: 'Search for a patron',
                        message: 'Enter a name, card number, or email above.',
                      );
                    }
                    if (state.patronResults.isEmpty) {
                      return const EmptyState(icon: Icons.person_off_outlined, title: 'No patrons found');
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.patronResults.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final p = state.patronResults[index];
                        final checkoutCount = state.patronCheckoutCounts[p.patronId] ?? 0;
                        final fineBalance = state.patronFineBalances[p.patronId] ?? 0;

                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => context.push(AppRoutes.staffPatronAccountPath(p.patronId)),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(color: ext.slate.withOpacity(0.15)),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.fullName,
                                          style: AppTypography.lora(fontSize: 14, fontWeight: FontWeight.w600)),
                                      Text(p.cardnumber,
                                          style: AppTypography.mono(fontSize: 11, color: ext.slate)),
                                      Text(p.email, style: AppTypography.inter(fontSize: 11, color: ext.slate)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: ext.primary.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text('$checkoutCount out',
                                          style: AppTypography.inter(fontSize: 10, color: ext.primary, fontWeight: FontWeight.w600)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'PKR ${fineBalance.toStringAsFixed(0)}',
                                      style: AppTypography.mono(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: fineBalance > 0 ? ext.stamp : ext.slate,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}