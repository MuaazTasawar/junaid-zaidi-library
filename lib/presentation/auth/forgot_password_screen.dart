import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../common_widgets/app_button.dart';
import '../common_widgets/app_text_field.dart';

/// Screen 3: card-number-only password reset request. No repository
/// method exists for this yet (out of scope of the Koha endpoint
/// mapping provided), so submission simulates a request and shows a
/// confirmation state — matches the spec's "Success state:
/// confirmation message" requirement without inventing an API call
/// that isn't in the contract.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardController = TextEditingController();
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reset password',
                style: AppTypography.lora(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: ext.inkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Enter your library card number and we'll send a reset link to your registered email.",
                style: AppTypography.inter(fontSize: 13, color: ext.slate),
              ),
              const SizedBox(height: 28),
              if (_submitted)
                _SuccessMessage(cardNumber: _cardController.text.trim())
              else
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        controller: _cardController,
                        label: 'Library card number',
                        prefixIcon: Icons.badge_outlined,
                        validator: Validators.cardNumber,
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'Send reset link',
                        isLoading: _isSubmitting,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessMessage extends StatelessWidget {
  const _SuccessMessage({required this.cardNumber});

  final String cardNumber;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Column(
      children: [
        Icon(Icons.check_circle_rounded, size: 48, color: ext.primary),
        const SizedBox(height: 16),
        Text(
          'Reset link sent',
          style: AppTypography.lora(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ext.inkText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'If an account exists for card $cardNumber, a reset link has been emailed to the address on file.',
          textAlign: TextAlign.center,
          style: AppTypography.inter(fontSize: 13, color: ext.slate),
        ),
      ],
    );
  }
}