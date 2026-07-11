import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_typography.dart';
import '../common_widgets/app_button.dart';
import '../common_widgets/book_cover.dart';
import 'staff_cubit.dart';
import 'staff_state.dart';

/// Screen 29: 2-step staff checkout flow — scan patron card, then
/// scan item — with a shared viewfinder for both steps and manual
/// entry fallback.
class StaffScanCheckoutScreen extends StatefulWidget {
  const StaffScanCheckoutScreen({super.key});

  @override
  State<StaffScanCheckoutScreen> createState() =>
      _StaffScanCheckoutScreenState();
}

class _StaffScanCheckoutScreenState extends State<StaffScanCheckoutScreen>
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

  void _handleDetect(
    BarcodeCapture capture,
    StaffCubit cubit,
    StaffState state,
  ) {
    final String? code = capture.barcodes.isNotEmpty
        ? capture.barcodes.first.rawValue
        : null;
    if (code == null || code == _lastCode) return;
    _lastCode = code;
    _submit(code, cubit, state);
  }

  void _submit(String value, StaffCubit cubit, StaffState state) {
    if (value.trim().isEmpty) return;
    if (state.scannedPatron == null) {
      cubit.scanPatronForCheckout(value.trim());
    } else {
      cubit.scanItemForCheckout(value.trim());
    }
    _manualController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<StaffCubit>(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('Scan to check out'),
          actions: [
            IconButton(
              icon: Icon(
                _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              ),
              onPressed: () {
                _cameraController.toggleTorch();
                setState(() => _torchOn = !_torchOn);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<StaffCubit, StaffState>(
            builder: (context, state) {
              final cubit = context.read<StaffCubit>();
              final bool step2 = state.scannedPatron != null;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StepChip(
                          label: '1. Scan patron card',
                          active: !step2,
                          done: step2,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Colors.white38,
                        ),
                        const SizedBox(width: 8),
                        _StepChip(
                          label: '2. Scan item',
                          active: step2,
                          done: false,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 220,
                    child: Stack(
                      children: [
                        MobileScanner(
                          controller: _cameraController,
                          onDetect: (capture) =>
                              _handleDetect(capture, cubit, state),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: SizedBox(
                              width: 200,
                              height: 140,
                              child: Stack(
                                children: [
                                  const _Bracket(alignment: Alignment.topLeft),
                                  const _Bracket(alignment: Alignment.topRight),
                                  const _Bracket(
                                    alignment: Alignment.bottomLeft,
                                  ),
                                  const _Bracket(
                                    alignment: Alignment.bottomRight,
                                  ),
                                  AnimatedBuilder(
                                    animation: _scanLineController,
                                    builder: (context, child) => Positioned(
                                      top: 140 * _scanLineController.value,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 2,
                                        color: const Color(0xFF2F5233),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Text(
                            'Align barcode within frame',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _manualController,
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (v) => _submit(v, cubit, state),
                      decoration: InputDecoration(
                        hintText: step2
                            ? 'Enter item barcode manually'
                            : 'Enter card number manually',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white12,
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () =>
                              _submit(_manualController.text, cubit, state),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  if (state.checkoutError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        state.checkoutError!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (state.scannedPatron != null)
                            _InfoCard(
                              title: state.scannedPatron!.fullName,
                              subtitle:
                                  '${state.scannedPatron!.cardnumber} · ${state.scannedPatronCheckoutCount} active checkouts',
                            ),
                          if (state.checkoutScannedItem != null &&
                              state.checkoutScannedBiblio != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                BookCover(
                                  title: state.checkoutScannedBiblio!.title,
                                  author: state.checkoutScannedBiblio!.author,
                                  subject: state.checkoutScannedBiblio!.subject,
                                  width: 44,
                                  height: 62,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.checkoutScannedBiblio!.title,
                                        style: AppTypography.lora(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        state
                                            .checkoutScannedItem!
                                            .itemcallnumber,
                                        style: AppTypography.mono(
                                          fontSize: 11,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 20),
                          if (step2 && state.checkoutScannedItem != null)
                            AppButton(
                              label: 'Confirm checkout',
                              isLoading: state.isConfirmingCheckout,
                              onPressed: () => cubit.confirmCheckout(),
                            ),
                          const SizedBox(height: 8),
                          AppButton(
                            label: 'Scan another',
                            variant: AppButtonVariant.text,
                            onPressed: () => cubit.resetCheckoutFlow(),
                          ),
                        ],
                      ),
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

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.label,
    required this.active,
    required this.done,
  });
  final String label;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2F5233) : Colors.white12,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active || done ? Colors.white : Colors.white54,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _Bracket extends StatelessWidget {
  const _Bracket({required this.alignment});
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final bool top = alignment.y < 0;
    final bool left = alignment.x < 0;
    return Align(
      alignment: alignment,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          border: Border(
            top: top
                ? const BorderSide(color: Color(0xFF2F5233), width: 3)
                : BorderSide.none,
            bottom: !top
                ? const BorderSide(color: Color(0xFF2F5233), width: 3)
                : BorderSide.none,
            left: left
                ? const BorderSide(color: Color(0xFF2F5233), width: 3)
                : BorderSide.none,
            right: !left
                ? const BorderSide(color: Color(0xFF2F5233), width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.mono(fontSize: 11, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
