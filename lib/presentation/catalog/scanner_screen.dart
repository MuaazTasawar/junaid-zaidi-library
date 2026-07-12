import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/di/service_locator.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../common_widgets/book_cover.dart';
import 'catalog_cubit.dart';
import 'catalog_state.dart';

/// Screen 9: barcode scanner — live camera viewfinder with animated
/// corner brackets + scan line, torch toggle, manual entry fallback,
/// and a "last scanned" result card.
///
/// The corner brackets and animated scan line are purely decorative
/// (Phase 18: wrapped in [ExcludeSemantics]) — a screen reader has no
/// use for "four L-shaped graphics" or a line that moves 60 times a
/// second. What matters is announced instead: the viewfinder region
/// has a semantic label explaining its purpose, and scan results are
/// a live region so success/failure is spoken automatically.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _cameraController = MobileScannerController();
  final TextEditingController _manualController = TextEditingController();
  late final AnimationController _scanLineController;
  bool _torchOn = false;
  String? _lastCode;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _manualController.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final String? code = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (code == null || code == _lastCode) return;
    _lastCode = code;
    context.read<CatalogCubit>().lookupBarcode(code);
  }

  void _submitManual() {
    final String value = _manualController.text.trim();
    if (value.isEmpty) return;
    _lastCode = value;
    context.read<CatalogCubit>().lookupBarcode(value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CatalogCubit>(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('Scan barcode'),
          actions: [
            Semantics(
              button: true,
              label: _torchOn ? 'Turn off flashlight' : 'Turn on flashlight',
              excludeSemantics: true,
              child: IconButton(
                icon: Icon(_torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded),
                onPressed: () {
                  _cameraController.toggleTorch();
                  setState(() => _torchOn = !_torchOn);
                },
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 260,
                child: Semantics(
                  label: 'Camera viewfinder. Align a barcode within the frame to scan, '
                      'or use manual entry below.',
                  child: Stack(
                    children: [
                      ExcludeSemantics(
                        child: MobileScanner(controller: _cameraController, onDetect: _onDetect),
                      ),
                      ExcludeSemantics(
                        child: Positioned.fill(
                          child: Center(
                            child: SizedBox(
                              width: 220,
                              height: 160,
                              child: Stack(
                                children: [
                                  const _CornerBracket(alignment: Alignment.topLeft),
                                  const _CornerBracket(alignment: Alignment.topRight),
                                  const _CornerBracket(alignment: Alignment.bottomLeft),
                                  const _CornerBracket(alignment: Alignment.bottomRight),
                                  AnimatedBuilder(
                                    animation: _scanLineController,
                                    builder: (context, child) {
                                      return Positioned(
                                        top: 160 * _scanLineController.value,
                                        left: 0,
                                        right: 0,
                                        child: Container(height: 2, color: const Color(0xFF2F5233)),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: ExcludeSemantics(
                          child: Text(
                            'Align barcode within frame',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _manualController,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => _submitManual(),
                  decoration: InputDecoration(
                    hintText: 'Enter barcode manually',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white12,
                    suffixIcon: Semantics(
                      button: true,
                      label: 'Submit barcode',
                      excludeSemantics: true,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                        onPressed: _submitManual,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<CatalogCubit, CatalogState>(
                  builder: (context, state) {
                    if (state.scanStatus == ScanStatus.scanning) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.scanStatus == ScanStatus.notFound) {
                      return Semantics(
                        liveRegion: true,
                        child: const Center(
                          child: Text('No item found for that barcode',
                              style: TextStyle(color: Colors.white70)),
                        ),
                      );
                    }
                    if (state.scanStatus == ScanStatus.found &&
                        state.scannedItem != null &&
                        state.scannedBiblio != null) {
                      return Semantics(
                        liveRegion: true,
                        child: _LastScannedCard(
                          title: state.scannedBiblio!.title,
                          author: state.scannedBiblio!.author,
                          subject: state.scannedBiblio!.subject,
                          barcode: state.scannedItem!.itemnumber.toString(),
                          onSearchCatalog: () => context
                              .push(AppRoutes.bookDetailPath(state.scannedBiblio!.biblioId)),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CornerBracket extends StatelessWidget {
  const _CornerBracket({required this.alignment});
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final bool top = alignment.y < 0;
    final bool left = alignment.x < 0;

    return Align(
      alignment: alignment,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: Color(0xFF2F5233), width: 3) : BorderSide.none,
            bottom: !top ? const BorderSide(color: Color(0xFF2F5233), width: 3) : BorderSide.none,
            left: left ? const BorderSide(color: Color(0xFF2F5233), width: 3) : BorderSide.none,
            right: !left ? const BorderSide(color: Color(0xFF2F5233), width: 3) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _LastScannedCard extends StatelessWidget {
  const _LastScannedCard({
    required this.title,
    required this.author,
    required this.subject,
    required this.barcode,
    required this.onSearchCatalog,
  });

  final String title;
  final String author;
  final String subject;
  final String barcode;
  final VoidCallback onSearchCatalog;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          BookCover(title: title, author: author, subject: subject, width: 50, height: 70),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.lora(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                Text(barcode,
                    style: AppTypography.mono(fontSize: 11, color: Colors.white70)),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: onSearchCatalog,
                  child: const Text('View details'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}