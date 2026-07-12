import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../auth/auth_cubit.dart';

/// Screen 17: digital library card — QR/barcode placeholders (no real
/// scan-target encoding is generated, per Golden Rule against faking
/// data the backend hasn't provided), and a static "Member since"
/// line since [Patron] has no enrollment-date field in the given Koha
/// mapping (see Phase 10 note above).
class LibraryCardScreen extends StatelessWidget {
  const LibraryCardScreen({super.key});

  static const String _memberSince = 'Sep 2023';

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    final patron = context.watch<AuthCubit>().state.patron;

    return Scaffold(
      appBar: AppBar(title: const Text('Library card')),
      body: Center(
        child: patron == null
            ? const CircularProgressIndicator()
            : Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ext.surface,
              border: Border.all(color: ext.primary, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: ext.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.menu_book_rounded, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text('Junaid Zaidi Library',
                    style: AppTypography.inter(fontSize: 12, color: ext.slate)),
                const SizedBox(height: 20),
                Text(patron.fullName,
                    style: AppTypography.lora(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(patron.cardnumber,
                    style: AppTypography.mono(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),
                Semantics(
                  label: 'QR code placeholder for library card barcode scanning '
                      '(visual representation only — not a functional scan target).',
                  child: ExcludeSemantics(
                    child: Container(
                      width: 100,
                      height: 100,
                      color: ext.inkText,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                        itemCount: 64,
                        itemBuilder: (context, index) => Container(
                          margin: const EdgeInsets.all(1),
                          color: (index * 7) % 3 == 0 ? ext.background : ext.inkText,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Semantics(
                  label: 'Barcode placeholder for card number ${patron.cardnumber} '
                      '(visual representation only — not a functional scan target).',
                  child: ExcludeSemantics(
                    child: Container(height: 40, color: ext.inkText, width: double.infinity),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Member since $_memberSince',
                        style: AppTypography.inter(fontSize: 11, color: ext.slate)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: ext.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(patron.categorycode,
                          style: AppTypography.inter(
                              fontSize: 10, fontWeight: FontWeight.w600, color: ext.gold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing coming soon')),
                  ),
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Share'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}