import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../auth/auth_cubit.dart';
import '../common_widgets/app_button.dart';
import '../common_widgets/book_cover.dart';
import 'catalog_cubit.dart';
import 'catalog_state.dart';

/// Screen 8: DraggableScrollableSheet for confirming a hold on the
/// currently-viewed biblio. Reads the confirmed biblio from
/// [CatalogCubit]'s already-loaded detail state — no re-fetch needed
/// since [BookDetailScreen] guarantees it's loaded before this sheet
/// can be opened.
class PlaceHoldSheet extends StatelessWidget {
  const PlaceHoldSheet({super.key, required this.biblioId});

  final int biblioId;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        final ext = Theme.of(context).extension<AppColorExtension>()!;

        return Container(
          decoration: BoxDecoration(
            color: ext.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: BlocBuilder<CatalogCubit, CatalogState>(
            builder: (context, state) {
              final biblio = state.selectedBiblio;
              final patron = context.watch<AuthCubit>().state.patron;

              if (biblio == null || patron == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ext.slate.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (state.holdSuccess)
                    _SuccessContent(biblioTitle: biblio.title)
                  else ...[
                    Row(
                      children: [
                        BookCover(
                          title: biblio.title,
                          author: biblio.author,
                          subject: biblio.subject,
                          width: 60,
                          height: 84,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            biblio.title,
                            style: AppTypography.lora(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Pickup branch', style: AppTypography.inter(fontSize: 12, color: ext.slate)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: ext.slate.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('COMSATS Main Library',
                          style: AppTypography.inter(fontSize: 14)),
                    ),
                    const SizedBox(height: 20),
                    Text('Confirming as', style: AppTypography.inter(fontSize: 12, color: ext.slate)),
                    const SizedBox(height: 6),
                    Text(patron.fullName,
                        style: AppTypography.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(patron.cardnumber, style: AppTypography.mono(fontSize: 12, color: ext.slate)),
                    if (state.holdErrorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(state.holdErrorMessage!,
                          style: AppTypography.inter(fontSize: 12, color: ext.stamp)),
                    ],
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Confirm hold',
                      isLoading: state.isPlacingHold,
                      onPressed: () => context.read<CatalogCubit>().placeHold(
                        patronId: patron.patronId,
                        biblioId: biblio.biblioId,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      label: 'Cancel',
                      variant: AppButtonVariant.text,
                      onPressed: () => context.pop(),
                    ),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({required this.biblioTitle});
  final String biblioTitle;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    return Column(
      children: [
        Icon(Icons.check_circle_rounded, size: 48, color: ext.primary),
        const SizedBox(height: 16),
        Text('Hold placed!',
            style: AppTypography.lora(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(
          'We\'ll notify you when "$biblioTitle" is ready for pickup.',
          textAlign: TextAlign.center,
          style: AppTypography.inter(fontSize: 13, color: ext.slate),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: 'Done',
          variant: AppButtonVariant.outlined,
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}