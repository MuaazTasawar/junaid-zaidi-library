import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/cover_color_resolver.dart';
import '../auth/auth_cubit.dart';
import '../common_widgets/app_button.dart';
import '../common_widgets/book_cover.dart';
import '../common_widgets/error_state.dart';
import '../common_widgets/loading_skeleton.dart';
import 'catalog_cubit.dart';
import 'catalog_state.dart';
import 'place_hold_sheet.dart';

/// Screen 7: full title detail — hero cover, metadata, availability,
/// call number, shelf location, description, related titles, and the
/// Place Hold / bookmark / share action bar.
class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, required this.biblioId});

  final int biblioId;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<CatalogCubit>().loadBiblioDetail(widget.biblioId);
    });
  }

  void _openPlaceHoldSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: sl<CatalogCubit>(),
        child: PlaceHoldSheet(biblioId: widget.biblioId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return BlocProvider.value(
      value: sl<CatalogCubit>(),
      child: Scaffold(
        body: BlocBuilder<CatalogCubit, CatalogState>(
          builder: (context, state) {
            if (state.detailStatus == DetailStatus.loading ||
                state.detailStatus == DetailStatus.idle) {
              return SafeArea(child: LoadingSkeleton.cards());
            }
            if (state.detailStatus == DetailStatus.error || state.selectedBiblio == null) {
              return SafeArea(
                child: ErrorState(
                  message: state.detailErrorMessage,
                  onRetry: () =>
                      context.read<CatalogCubit>().loadBiblioDetail(widget.biblioId),
                  onGoHome: () => context.pop(),
                ),
              );
            }

            final biblio = state.selectedBiblio!;
            final int available = state.availableCopiesForSelected;
            final bool isBookmarked = state.bookmarkedBiblioIds.contains(biblio.biblioId);
            final callNumber = state.selectedItems.isNotEmpty
                ? state.selectedItems.first.itemcallnumber
                : '—';
            final location = state.selectedItems.isNotEmpty
                ? state.selectedItems.first.location
                : 'Location unavailable';

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 220,
                  leading: BackButton(onPressed: () => context.pop()),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: 'book-cover-${biblio.biblioId}',
                      child: SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: BookCover(
                            title: biblio.title,
                            author: biblio.author,
                            subject: biblio.subject,
                            width: 400,
                            height: 220,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(biblio.title,
                          style: AppTypography.lora(fontSize: 20, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(
                        '${biblio.author} · ${biblio.edition}',
                        style: AppTypography.mono(fontSize: 12, color: ext.slate),
                      ),
                      Text('ISBN ${biblio.isbn}',
                          style: AppTypography.mono(fontSize: 12, color: ext.slate)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: CoverColorResolver.accentFor(biblio.subject).withOpacity(0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          biblio.subject,
                          style: AppTypography.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: CoverColorResolver.accentFor(biblio.subject),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            available > 0 ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            size: 18,
                            color: available > 0 ? ext.primary : ext.stamp,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            available > 0 ? '$available copies available' : 'Unavailable',
                            style: AppTypography.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: available > 0 ? ext.primary : ext.stamp,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Call number', style: AppTypography.inter(fontSize: 11, color: ext.slate)),
                      Text(callNumber, style: AppTypography.mono(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Shelf location', style: AppTypography.inter(fontSize: 11, color: ext.slate)),
                      Text(location, style: AppTypography.inter(fontSize: 13)),
                      const SizedBox(height: 16),
                      Text(biblio.description, style: AppTypography.inter(fontSize: 13, height: 1.5)),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(
                          5,
                              (i) => Icon(Icons.star_rounded, size: 18, color: ext.gold),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Place Hold',
                              onPressed: () => _openPlaceHoldSheet(context),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () =>
                                context.read<CatalogCubit>().toggleBookmark(biblio.biblioId),
                            icon: Icon(
                              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              color: ext.primary,
                            ),
                          ),
                          IconButton(
                            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sharing coming soon')),
                            ),
                            icon: const Icon(Icons.share_outlined),
                          ),
                        ],
                      ),
                      if (state.relatedBiblios.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Text('Related books',
                            style: AppTypography.lora(fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 150,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.relatedBiblios.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final related = state.relatedBiblios[index];
                              return GestureDetector(
                                onTap: () =>
                                    context.push(AppRoutes.bookDetailPath(related.biblioId)),
                                child: BookCover(
                                  title: related.title,
                                  author: related.author,
                                  subject: related.subject,
                                  width: 100,
                                  height: 140,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ]),
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