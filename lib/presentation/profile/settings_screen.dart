import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 23: app version, cache clearing, issue reporting, privacy
/// policy link, and Koha instance connection info.
///
/// The connection indicator reflects [useMock] honestly (see Phase 12
/// note above) rather than a fabricated "Connected" status.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String _appVersion = '0.1.0';

  Future<void> _clearCache(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear cache?'),
        content: const Text(
          'This clears locally cached preferences and saved searches. Your library account is unaffected.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Clear')),
        ],
      ),
    );

    if (confirmed == true) {
      for (final boxName in ['searchBox', 'bookmarksBox', 'savedSearchesBox']) {
        final box = await Hive.openBox(boxName);
        await box.clear();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cache cleared')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline_rounded, color: ext.inkText),
            title: const Text('App version'),
            trailing: Text(_appVersion, style: AppTypography.mono(fontSize: 13, color: ext.slate)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.cleaning_services_outlined, color: ext.inkText),
            title: const Text('Clear cache'),
            onTap: () => _clearCache(context),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.flag_outlined, color: ext.inkText),
            title: const Text('Report an issue'),
            onTap: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Report a bug via the thumbs-down button, or email library@comsats.edu.pk'))),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.privacy_tip_outlined, color: ext.inkText),
            title: const Text('Privacy policy'),
            onTap: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Privacy policy coming soon'))),
          ),
          const Divider(height: 32),
          Text('About LibConnect',
              style: AppTypography.lora(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            'LibConnect is a native mobile client for the Junaid Zaidi Library at COMSATS University Islamabad, built on Koha LMS.',
            style: AppTypography.inter(fontSize: 13, color: ext.slate),
          ),
          const SizedBox(height: 24),
          Text('Koha instance', style: AppTypography.lora(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: ext.slate.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Branch', value: 'COMSATS Main Library', ext: ext),
                const SizedBox(height: 8),
                _InfoRow(
                  label: 'Server URL',
                  value: useMock ? 'Not configured (mock mode)' : '—',
                  ext: ext,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Status', style: AppTypography.inter(fontSize: 12, color: ext.slate)),
                    const Spacer(),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: useMock ? ext.slate : ext.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      useMock ? 'Mock data (not connected)' : 'Connected',
                      style: AppTypography.inter(
                          fontSize: 12, fontWeight: FontWeight.w600, color: useMock ? ext.slate : ext.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, required this.ext});
  final String label;
  final String value;
  final AppColorExtension ext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTypography.inter(fontSize: 12, color: ext.slate)),
        const Spacer(),
        Text(value, style: AppTypography.inter(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}