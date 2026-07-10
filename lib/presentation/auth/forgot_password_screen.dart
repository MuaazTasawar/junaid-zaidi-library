import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../common_widgets/app_button.dart';
import '../common_widgets/app_text_field.dart';
import 'auth_cubit.dart';
import 'auth_state.dart';

/// Screen 2: library card number + password login, routing to
/// patron home or staff home based on the returned patron's
/// `categorycode` (handled centrally in [AuthCubit]/[SplashScreen]
/// redirect logic, mirrored here for the direct post-submit case).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _cardController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
      cardnumber: _cardController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticatedPatron) {
            context.go(AppRoutes.home);
          } else if (state.status == AuthStatus.authenticatedStaff) {
            context.go(AppRoutes.staffHome);
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: ext.primary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: AppTypography.lora(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: ext.inkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign in with your library card to continue',
                      textAlign: TextAlign.center,
                      style: AppTypography.inter(fontSize: 13, color: ext.slate),
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      controller: _cardController,
                      label: 'Library card number',
                      hintText: 'e.g. FA23-BCS-050',
                      prefixIcon: Icons.badge_outlined,
                      validator: Validators.cardNumber,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: true,
                      showObscureToggle: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Sign In',
                      isLoading: state.isSubmitting,
                      onPressed: () => _submit(context),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: AppButton(
                        label: 'Forgot password?',
                        variant: AppButtonVariant.text,
                        fullWidth: false,
                        onPressed: () => context.push(AppRoutes.forgotPassword),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: AppButton(
                        label: 'Sign in as staff member',
                        variant: AppButtonVariant.text,
                        fullWidth: false,
                        onPressed: () {
                          _cardController.text = 'STAFF-0001';
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}