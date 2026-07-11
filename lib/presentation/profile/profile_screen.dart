import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/di/service_locator.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../auth/auth_cubit.dart';
import '../theme/app_theme_cubit.dart';
import '../theme/app_theme_state.dart';
import 'profile_cubit.dart';
import 'profile_state.dart';

/// Screen 21: profile hub — avatar (initials or picked photo), name,
/// card number, stat row, and 3 grouped menu sections (Account /
/// Preferences / Library), plus Sign Out.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patron = context.read<AuthCubit>().state.patron;
      if (patron != null) sl<ProfileCubit>().loadStats(patron.patronId);
    });
  }

  Future<void> _pickAvatar(BuildContext context) async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      // ignore: use_build_context_synchronously
      context.read<ProfileCubit>().setAvatarPath(picked.path);
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You\'ll need your library card and password to sign back in.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthCubit>().logout();
      if (context.mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    final patron = context.watch<AuthCubit>().state.patron;

    return BlocProvider.value(
      value: sl<ProfileCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: patron == null
            ? const Center(child: CircularProgressIndicator())
            : BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: ext.primary,
                        backgroundImage:
                        state.avatarPath != null ? FileImage(File(state.avatarPath!)) : null,
                        child: state.avatarPath == null
                            ? Text(
                          patron.firstname.isNotEmpty ? patron.firstname[0] : '?',
                          style: AppTypography.lora(
                              fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white),
                        )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _pickAvatar(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: ext.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: ext.background, width: 2),
                            ),
                            child: Icon(Icons.edit_rounded, size: 14, color: ext.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(patron.fullName,
                      style: AppTypography.lora(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
                Center(
                  child: Text(patron.cardnumber,
                      style: AppTypography.mono(fontSize: 12, color: ext.slate)),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ext.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Active patron',
                        style: AppTypography.inter(
                            fontSize: 11, fontWeight: FontWeight.w600, color: ext.primary)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                        child: _StatChip(
                            label: 'Books read', value: '${state.booksReadCount}', ext: ext)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _StatChip(
                            label: 'Active holds', value: '${state.activeHoldsCount}', ext: ext)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatChip(
                        label: 'Fines',
                        value: 'PKR ${state.outstandingFines.toStringAsFixed(0)}',
                        ext: ext,
                        tint: state.outstandingFines > 0 ? ext.stamp : ext.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionLabel(text: 'ACCOUNT', ext: ext),
                _MenuTile(icon: Icons.history_rounded, label: 'Borrowing history', onTap: () => context.push(AppRoutes.history)),
                _MenuTile(icon: Icons.badge_outlined, label: 'Library card', onTap: () => context.push(AppRoutes.libraryCard)),
                _MenuTile(icon: Icons.bookmark_border_rounded, label: 'Saved searches', onTap: () => context.push(AppRoutes.savedSearches)),
                const SizedBox(height: 16),
                _SectionLabel(text: 'PREFERENCES', ext: ext),
                BlocBuilder<AppThemeCubit, AppThemeState>(
                  builder: (context, themeState) {
                    return SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(Icons.dark_mode_outlined, color: ext.inkText),
                      title: const Text('Dark mode'),
                      value: themeState.themeMode == ThemeMode.dark,
                      onChanged: (_) => context.read<AppThemeCubit>().toggleLightDark(),
                    );
                  },
                ),
                _MenuTile(icon: Icons.notifications_outlined, label: 'Notification settings', onTap: () => context.push(AppRoutes.notificationPrefs)),
                _MenuTile(icon: Icons.tune_rounded, label: 'Personalization', onTap: () => context.push(AppRoutes.personalization)),
                _MenuTile(icon: Icons.settings_outlined, label: 'Settings', onTap: () => context.push(AppRoutes.settings)),
                const SizedBox(height: 16),
                _SectionLabel(text: 'LIBRARY', ext: ext),
                _MenuTile(
                  icon: Icons.info_outline_rounded,
                  label: 'Library info',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Junaid Zaidi Library, COMSATS University Islamabad')),
                  ),
                ),
                _MenuTile(
                  icon: Icons.mail_outline_rounded,
                  label: 'Contact us',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('library@comsats.edu.pk')),
                  ),
                ),
                _MenuTile(
                  icon: Icons.help_outline_rounded,
                  label: 'FAQs',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('FAQs coming soon')),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.logout_rounded, color: ext.stamp),
                  title: Text('Sign out', style: TextStyle(color: ext.stamp)),
                  onTap: () => _confirmSignOut(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, required this.ext, this.tint});
  final String label;
  final String value;
  final AppColorExtension ext;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final Color color = tint ?? ext.primary;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(value, style: AppTypography.mono(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.inter(fontSize: 10, color: ext.slate)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.ext});
  final String text;
  final AppColorExtension ext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(text,
          style: AppTypography.inter(fontSize: 11, fontWeight: FontWeight.w600, color: ext.slate, letterSpacing: 0.6)),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: ext.inkText),
      title: Text(label, style: AppTypography.inter(fontSize: 14)),
      trailing: Icon(Icons.chevron_right_rounded, color: ext.slate),
      onTap: onTap,
    );
  }
}