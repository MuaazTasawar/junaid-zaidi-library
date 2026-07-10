import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/cover_color_resolver.dart';
import '../../data/models/biblio.dart';
import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';
import '../common_widgets/app_button.dart';
import '../common_widgets/book_cover.dart';
import '../common_widgets/due_date_stamp.dart';
import '../common_widgets/empty_state.dart';
import '../common_widgets/error_state.dart';
import '../common_widgets/loading_skeleton.dart';
import '../common_widgets/subject_card.dart';
import 'home_cubit.dart';
import 'home_state.dart';

/// Screen 4: patron dashboard — overdue alert, search entry, currently
/// borrowed strip, subject browse grid, new arrivals strip, and quick
/// actions row.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (_) {
        final cubit = sl<HomeCubit>();
        final authState = context.read<AuthCubit>().state;
        if (authState.patron != null) {
          cubit.loadHome(authState.patron!);
        }
        return cubit;
      },
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text('LibConnect', style: AppTypography.lora(fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go(AppRoutes.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.go(AppRoutes.profile),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading) {
            return LoadingSkeleton.home(context);
          }
          if (state.status == HomeStatus.error) {
            return ErrorState(
              message: state.errorMessage,
              onRetry: () {
                final patron = state.patron;
                if (patron != null) context.read<HomeCubit>().loadHome(patron);
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final patron = state.patron;
              if (patron != null) {
                await context.read<HomeCubit>().loadHome(patron);
              }
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Welcome back, ${state.patron?.firstname ?? ''}',
                    style: AppTypography.inter(fontSize: 15, color: ext.slate),
                  ),
                ),
                if (state.overdueCount > 0) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _OverdueBanner(count: state.overdueCount),
                  ),
                ],
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SearchBar(
                    onTapSearch: () => context.go(AppRoutes.search),
                    onTapScan: () => context.push(AppRoutes.scanner),
                  ),
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Currently borrowed',
                  onSeeAll: () => context.go(AppRoutes.checkouts),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 190,
                  child: state.borrowedItems.isEmpty
                      ? const Center(
                    child: EmptyState(
                      icon: Icons.menu_book_outlined,
                      title: 'Nothing checked out',
                      message: 'Browse the catalog to find your next read.',
                    ),
                  )
                      : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.borrowedItems.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final view = state.borrowedItems[index];
                      return _BorrowedCard(
                        view: view,
                        onTap: () => context
                            .push(AppRoutes.bookDetailPath(view.biblio.biblioId)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Browse by subject',
                    style: AppTypography.lora(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: CoverColorResolver.browsableSubjects
                        .map((subject) => SubjectCard(
                      subject: subject,
                      onTap: () =>
                          context.push(AppRoutes.subjectBrowsePath(subject)),
                    ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'New arrivals',
                    style: AppTypography.lora(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 168,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.newArrivals.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final Biblio biblio = state.newArrivals[index];
                      return _NewArrivalCard(
                        biblio: biblio,
                        onTap: () =>
                            context.push(AppRoutes.bookDetailPath(biblio.biblioId)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _QuickActionsRow(
                    isRenewingAll: state.isRenewingAll,
                    onSearch: () => context.go(AppRoutes.search),
                    onHolds: () => context.go(AppRoutes.holds),
                    onRenewAll: () => context.read<HomeCubit>().renewAll(),
                    onPayFines: () => context.go(AppRoutes.fines),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OverdueBanner extends StatelessWidget {
  const _OverdueBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ext.stamp.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: ext.stamp, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You have $count overdue ${count == 1 ? 'item' : 'items'}',
              style: AppTypography.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ext.stamp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTapSearch, required this.onTapScan});
  final VoidCallback onTapSearch;
  final VoidCallback onTapScan;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    return Material(
      color: ext.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTapSearch,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ext.slate.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: ext.slate, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search the catalog',
                  style: AppTypography.inter(fontSize: 14, color: ext.slate),
                ),
              ),
              InkWell(
                onTap: onTapScan,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.qr_code_scanner_rounded, color: ext.primary, size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: AppTypography.lora(fontSize: 16, fontWeight: FontWeight.w600)),
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See all',
              style: AppTypography.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ext.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BorrowedCard extends StatelessWidget {
  const _BorrowedCard({required this.view, required this.onTap});
  final BorrowedItemView view;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'book-cover-${view.biblio.biblioId}',
              child: BookCover(
                title: view.biblio.title,
                author: view.biblio.author,
                subject: view.biblio.subject,
                width: 110,
                height: 130,
              ),
            ),
            const SizedBox(height: 6),
            DueDateStamp(dueDate: view.checkout.dueDate),
          ],
        ),
      ),
    );
  }
}

class _NewArrivalCard extends StatelessWidget {
  const _NewArrivalCard({required this.biblio, required this.onTap});
  final Biblio biblio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'book-cover-${biblio.biblioId}',
              child: BookCover(
                title: biblio.title,
                author: biblio.author,
                subject: biblio.subject,
                width: 100,
                height: 130,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.isRenewingAll,
    required this.onSearch,
    required this.onHolds,
    required this.onRenewAll,
    required this.onPayFines,
  });

  final bool isRenewingAll;
  final VoidCallback onSearch;
  final VoidCallback onHolds;
  final VoidCallback onRenewAll;
  final VoidCallback onPayFines;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: 'Search',
            variant: AppButtonVariant.outlined,
            onPressed: onSearch,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppButton(
            label: 'My Holds',
            variant: AppButtonVariant.outlined,
            onPressed: onHolds,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppButton(
            label: 'Renew All',
            variant: AppButtonVariant.outlined,
            isLoading: isRenewingAll,
            onPressed: onRenewAll,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppButton(
            label: 'Pay Fines',
            variant: AppButtonVariant.outlined,
            onPressed: onPayFines,
          ),
        ),
      ],
    );
  }
}