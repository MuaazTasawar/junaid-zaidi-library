import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../common_widgets/book_cover.dart';
import 'catalog_cubit.dart';
import 'catalog_state.dart';

/// Screen 5: search entry point — autofocused search bar, recent
/// searches (max 10, persisted in Hive via [CatalogCubit]), a
/// "Popular at COMSATS" strip, and a barcode-scan FAB.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final String query = value.trim();
    if (query.isEmpty) return;
    context.push('${AppRoutes.searchResults}?q=${Uri.encodeComponent(query)}');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CatalogCubit>(),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(AppRoutes.scanner),
          child: const Icon(Icons.qr_code_scanner_rounded),
        ),
        body: SafeArea(
          child: BlocBuilder<CatalogCubit, CatalogState>(
            builder: (context, state) {
              final ext = Theme.of(context).extension<AppColorExtension>()!;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    onSubmitted: _submit,
                    decoration: InputDecoration(
                      hintText: 'Search title, author, ISBN...',
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (state.recentSearches.isNotEmpty) ...[
                    Text('Recent searches',
                        style: AppTypography.lora(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.recentSearches
                          .map((term) => ActionChip(
                        label: Text(term),
                        onPressed: () {
                          _controller.text = term;
                          _submit(term);
                        },
                      ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text('Popular at COMSATS',
                      style: AppTypography.lora(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 160,
                    child: state.popularBiblios.isEmpty
                        ? Center(
                      child: Text('Loading...',
                          style: AppTypography.inter(color: ext.slate)),
                    )
                        : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.popularBiblios.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final biblio = state.popularBiblios[index];
                        return GestureDetector(
                          onTap: () => context
                              .push(AppRoutes.bookDetailPath(biblio.biblioId)),
                          child: Hero(
                            tag: 'book-cover-${biblio.biblioId}',
                            child: BookCover(
                              title: biblio.title,
                              author: biblio.author,
                              subject: biblio.subject,
                              width: 100,
                              height: 140,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}