import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../common_widgets/app_button.dart';
import '../common_widgets/book_cover.dart';
import '../common_widgets/due_date_stamp.dart';
import '../common_widgets/status_badge.dart';
import 'staff_cubit.dart';
import 'staff_state.dart';

/// Screen 30: staff check-in flow — scan item, show previous
/// borrower + due date, pick a condition (Good/Damaged/Lost), confirm
/// check-in.
class StaffScanCheckinScreen extends StatefulWidget {
  const StaffScanCheckinScreen({super.key});

  @override
  State<StaffScanCheckinScreen> createState() => _StaffScanCheckinScreenState();
}

class _StaffScanCheckinScreenState extends State<StaffScanCheckinScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _cameraController = MobileScannerController();
  final TextEditingController _manualController = TextEditingController();
  late final AnimationController _scanLineController;
  bool _torchOn = false;
  String? _lastCode;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _manualController.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  void _handleDetect(BarcodeCapture capture, StaffCubit cubit) {
    final String? code = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (code == null || code == _lastCode) return;
    _lastCode = code;
    cubit.scanItemForCheckin(code);
  }

  void _submitManual(StaffCubit cubit) {
    final value = _manualController.text.trim();
    if (value.isEmpty) return;
    cubit.scanItemForCheckin(value);
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
          title: const Text('Scan to check in'),
          actions: [
            IconButton(
              icon: Icon(_torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded),
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

              return Column(
                children: [
                  SizedBox(
                    height: 220,
                    child: Stack(
                      children: [
                        MobileScanner(
                          controller: _cameraController,
                          onDetect: (capture) => _handleDetect(capture, cubit),
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
                                  const _Bracket(alignment: Alignment.bottomLeft),
                                  const _Bracket(alignment: Alignment.bottomRight),
                                  AnimatedBuilder(
                                    animation: _scanLineController,
                                    builder: (context, child) => Positioned(
                                      top: 140 * _scanLineController.value,
                                      left: 0,
                                      right: 0,
                                      child: Container(height: 2, color: const Color(0xFF2F5233)),
                                    ),
                                  ),
                                ],
                              ),
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
                      onSubmitted: (_) => _submitManual(cubit),
                      decoration: InputDecoration(
                        hintText: 'Enter item barcode manually',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white12,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                          onPressed: () => _submitManual(cubit),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  if (state.checkinError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(state.checkinError!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: state.checkinScannedItem == null
                          ? const SizedBox.shrink()
                          : Column(
                        children: [
                          Row(
                            children: [
                              BookCover(
                                title: state.checkinScannedBiblio!.title,
                                author: state.checkinScannedBiblio!.author,
                                subject: state.checkinScannedBiblio!.subject,
                                width: 50, height: 70,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(state.checkinScannedBiblio!.title,
                                        style: AppTypography.lora(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                                    if (state.checkinPreviousPatron != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Previously checked out by ${state.checkinPreviousPatron!.fullName}',
                                        style: AppTypography.inter(fontSize: 12, color: Colors.white70),
                                      ),
                                    ] else
                                      Text('Not currently on loan',
                                          style: AppTypography.inter(fontSize: 12, color: Colors.white54)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (state.checkinPreviousCheckout != null) ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: DueDateStamp(dueDate: state.checkinPreviousCheckout!.dueDate),
                            ),
                          ],
                          if (state.checkinSuccess) ...[
                            const SizedBox(height: 16),
                            const StatusBadge(label: 'Available', kind: StatusBadgeKind.available),
                          ],
                          const SizedBox(height: 20),
                          if (state.checkinPreviousCheckout != null && !state.checkinSuccess) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Condition',
                                  style: AppTypography.inter(fontSize: 12, color: Colors.white70)),
                            ),
                            const SizedBox(height: 8),
                            SegmentedButton<ItemCondition>(
                              segments: const [
                                ButtonSegment(value: ItemCondition.good, label: Text('Good')),
                                ButtonSegment(value: ItemCondition.damaged, label: Text('Damaged')),
                                ButtonSegment(value: ItemCondition.lost, label: Text('Lost')),
                              ],
                              selected: {state.checkinCondition},
                              onSelectionChanged: (s) => cubit.setCheckinCondition(s.first),
                            ),
                            const SizedBox(height: 20),
                            AppButton(
                              label: 'Confirm check-in',
                              isLoading: state.isConfirmingCheckin,
                              onPressed: () => cubit.confirmCheckin(),
                            ),
                          ],
                          const SizedBox(height: 8),
                          AppButton(
                            label: 'Scan another',
                            variant: AppButtonVariant.text,
                            onPressed: () => cubit.resetCheckinFlow(),
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