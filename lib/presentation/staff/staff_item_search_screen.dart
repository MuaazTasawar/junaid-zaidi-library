import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/item.dart';
import '../common_widgets/empty_state.dart';
import '../common_widgets/loading_skeleton.dart';
import '../common_widgets/status_badge.dart';
import 'staff_cubit.dart';
import 'staff_state.dart';

/// Screen 33: staff item search by title/barcode/ISBN/call number,
/// with a status badge per result derived from item fields (see
/// Phase 9 note: "on hold" can't be distinguished without a
/// holds-by-biblio endpoint, so only Available/On loan/Lost show).
class StaffItemSearchScreen extends StatefulWidget {
  const StaffItemSearchScreen({super.key});

  @override
  State<StaffItemSearchScreen> createState() => _StaffItemSearchScreenState();
}

class _StaffItemSearchScreenState extends State<StaffItemSearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<StaffCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Search item')),
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
                    onSubmitted: cubit.searchItems,
                    decoration: InputDecoration(
                      hintText: 'Title, barcode, ISBN, or call number',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward_rounded),
                        onPressed: () => cubit.searchItems(_controller.text),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Builder(builder: (context) {
                    if (state.itemSearchStatus == SectionStatus.loading) {
                      return LoadingSkeleton.list();
                    }
                    if (state.itemSearchStatus == SectionStatus.idle) {
                      return const EmptyState(
                        icon: Icons.menu_book_outlined,
                        title: 'Search for an item',
                      );
                    }
                    if (state.itemResults.isEmpty) {
                      return const EmptyState(icon: Icons.search_off_rounded, title: 'No items found');
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.itemResults.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = state.itemResults[index];
                        return _ItemResultTile(
                          item: item,
                          onTap: () => context.push(AppRoutes.staffItemDetailPath(item.itemId)),
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

class _ItemResultTile extends StatelessWidget {
  const _ItemResultTile({required this.item, required this.onTap});
  final Item item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

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

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: ext.slate.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.itemcallnumber,
                      style: AppTypography.mono(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('Barcode ${item.itemnumber}',
                      style: AppTypography.inter(fontSize: 11, color: ext.slate)),
                ],
              ),
            ),
            StatusBadge(label: label, kind: kind),
          ],
        ),
      ),
    );
  }
}