import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../common_widgets/book_cover.dart';
import '../common_widgets/empty_state.dart';
import '../common_widgets/error_state.dart';
import '../common_widgets/loading_skeleton.dart';
import '../common_widgets/status_badge.dart';
import 'catalog_cubit.dart';
import 'catalog_state.dart';

/// Screen 6: result list for a search query (`?q=` query param),
/// with static filter chips (visual only — no backing filter logic
/// exists in the repository contract), a sort dropdown, and
/// Hero-transitioning result cards into [BookDetailScreen].
class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key, required this.initialQuery});

  final String initialQuery;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<CatalogCubit>().search(widget.initialQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CatalogCubit>(),
      child: Scaffold(
        appBar: AppBar(title: Text('"${widget.initialQuery}"')),
        body: BlocBuilder<CatalogCubit, CatalogState>(
          builder: (context, state) {
            if (state.searchStatus == SearchStatus.loading) {
              return LoadingSkeleton.list();
            }
            if (state.searchStatus == SearchStatus.error) {
              return ErrorState(
                message: state.searchErrorMessage,
                onRetry: () => context.read<CatalogCubit>().search(widget.initialQuery),
              );
            }
            if (state.results.isEmpty) {
              return const EmptyState(
                icon: Icons.search_off_rounded,
                title: 'No books found',
                message: 'Try a different title, author, or ISBN.',
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${state.results.length} results',
                          style: AppTypography.inter(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      DropdownButton<SortOption>(
                        value: state.sortOption,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(value: SortOption.relevance, child: Text('Relevance')),
                          DropdownMenuItem(value: SortOption.titleAsc, child: Text('Title A-Z')),
                          DropdownMenuItem(value: SortOption.newest, child: Text('Newest')),
                        ],
                        onChanged: (option) {
                          if (option != null) {
                            context.read<CatalogCubit>().changeSortOption(option);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: const [
                      _FilterChip(label: 'Subject'),
                      SizedBox(width: 8),
                      _FilterChip(label: 'Available now'),
                      SizedBox(width: 8),
                      _FilterChip(label: 'Location'),
                      SizedBox(width: 8),
                      _FilterChip(label: 'Year'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final biblio = state.results[index];
                      return _BookResultCard(
                        biblio: biblio,
                        onTap: () => context.push(AppRoutes.bookDetailPath(biblio.biblioId)),
                      );
                    },
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      avatar: const Icon(Icons.filter_list_rounded, size: 16),
    );
  }
}

class _BookResultCard extends StatelessWidget {
  const _BookResultCard({required this.biblio, required this.onTap});
  final dynamic biblio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'book-cover-${biblio.biblioId}',
            child: BookCover(
              title: biblio.title,
              author: biblio.author,
              subject: biblio.subject,
              width: 56,
              height: 78,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(biblio.title,
                    style: AppTypography.lora(fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(biblio.author,
                    style: AppTypography.inter(fontSize: 12, color: ext.slate)),
                const SizedBox(height: 6),
                const StatusBadge(label: 'Available', kind: StatusBadgeKind.available),
              ],
            ),
          ),
        ],
      ),
    );
  }
}