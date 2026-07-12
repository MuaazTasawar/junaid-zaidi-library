import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';

/// Shimmer-based loading skeletons (Screen 27). Every screen must
/// show one of these while its Cubit is in a loading state â€” never a
/// bare [CircularProgressIndicator] (Golden Rule #5).
class LoadingSkeleton {
  const LoadingSkeleton._();

  static Widget home(BuildContext context) => _ShimmerWrap(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar(width: 180, height: 20),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: List.generate(
                  3,
                      (i) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _block(width: 100, height: 140),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _bar(width: 140, height: 16),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: List.generate(6, (i) => _block(height: 64)),
          ),
        ],
      ),
    ),
  );

  static Widget list({int rows = 5}) => _ShimmerWrap(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          rows,
              (i) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                _block(width: 40, height: 56),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bar(width: double.infinity, height: 14),
                      const SizedBox(height: 8),
                      _bar(width: 120, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  static Widget cards({int count = 3}) => _ShimmerWrap(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          count,
              (i) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _block(height: 90),
          ),
        ),
      ),
    ),
  );

  static Widget profile(BuildContext context) => _ShimmerWrap(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _circle(size: 72),
          const SizedBox(height: 16),
          _bar(width: 140, height: 16),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) => _block(width: 90, height: 60)),
          ),
          const SizedBox(height: 24),
          ...List.generate(
            4,
                (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _bar(width: double.infinity, height: 44),
            ),
          ),
        ],
      ),
    ),
  );

  static Widget _bar({double width = double.infinity, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  static Widget _block({double? width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  static Widget _circle({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    );
  }
}

class _ShimmerWrap extends StatelessWidget {
  const _ShimmerWrap({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? ext.surface : ext.slate.withOpacity(0.15),
      highlightColor: isDark ? ext.slate.withOpacity(0.25) : Colors.white,
      child: child,
    );
  }
}