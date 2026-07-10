import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/routing/app_routes.dart';
import '../common_widgets/book_cover.dart';
import '../common_widgets/empty_state.dart';
import '../common_widgets/error_state.dart';
import '../common_widgets/loading_skeleton.dart';
import 'catalog_cubit.dart';
import 'catalog_state.dart';

/// Screen 10: 2-column grid of a single subject's catalog, with
/// static filter chips (Availability / Year / Location — visual only,
/// same rationale as SearchResultsScreen's filter row).
class SubjectBrowseScreen extends StatefulWidget {
  const SubjectBrowseScreen({super.key, required this.subject});

  final String subject;

  @override
  State<SubjectBrowseScreen> createState() => _SubjectBrowseScreenState();
}

class _SubjectBrowseScreenState extends State<SubjectBrowseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<CatalogCubit>().browseSubject(widget.subject);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CatalogCubit>(),
      child: Scaffold(
        appBar: AppBar(title: Text(widget.subject)),
        body: Column(
          children: [
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                children: const [
                  Chip(label: Text('Availability')),
                  SizedBox(width: 8),
                  Chip(label: Text('Year')),
                  SizedBox(width: 8),
                  Chip(label: Text('Location')),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<CatalogCubit, CatalogState>(
                builder: (context, state) {
                  if (state.subjectBrowseStatus == SearchStatus.loading) {
                    return LoadingSkeleton.list();
                  }
                  if (state.subjectBrowseStatus == SearchStatus.error) {
                    return ErrorState(
                      message: state.subjectBrowseErrorMessage,
                      onRetry: () =>
                          context.read<CatalogCubit>().browseSubject(widget.subject),
                    );
                  }
                  if (state.subjectBrowseResults.isEmpty) {
                    return const EmptyState(
                      icon: Icons.menu_book_outlined,
                      title: 'No titles in this subject yet',
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: state.subjectBrowseResults.length,
                    itemBuilder: (context, index) {
                      final biblio = state.subjectBrowseResults[index];
                      return GestureDetector(
                        onTap: () =>
                            context.push(AppRoutes.bookDetailPath(biblio.biblioId)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Hero(
                                tag: 'book-cover-${biblio.biblioId}',
                                child: BookCover(
                                  title: biblio.title,
                                  author: biblio.author,
                                  subject: biblio.subject,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              biblio.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}