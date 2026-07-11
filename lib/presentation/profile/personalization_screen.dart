import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/cover_color_resolver.dart';
import '../common_widgets/app_button.dart';
import 'profile_cubit.dart';
import 'profile_state.dart';

/// Screen 22: preferred subjects multi-select, reading language
/// radio, preferred branch dropdown (single COMSATS option per the
/// mock branch scope), and font size slider.
class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  late Set<String> _subjects;
  late ReadingLanguage _language;
  late String _branch;
  late FontSizeOption _fontSize;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return BlocProvider.value(
      value: sl<ProfileCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Personalization')),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (!_initialized) {
              _subjects = Set.of(state.preferredSubjects);
              _language = state.readingLanguage;
              _branch = state.preferredBranch;
              _fontSize = state.fontSize;
              _initialized = true;
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Preferred subjects',
                    style: AppTypography.lora(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.6,
                  children: CoverColorResolver.browsableSubjects.map((subject) {
                    final bool selected = _subjects.contains(subject);
                    return GestureDetector(
                      onTap: () => setState(() {
                        selected ? _subjects.remove(subject) : _subjects.add(subject);
                      }),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected ? ext.primary.withOpacity(0.14) : Colors.transparent,
                          border: Border.all(color: selected ? ext.primary : ext.slate.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(subject,
                            style: AppTypography.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected ? ext.primary : ext.inkText)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text('Reading language',
                    style: AppTypography.lora(fontSize: 15, fontWeight: FontWeight.w600)),
                RadioListTile<ReadingLanguage>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('English'),
                  value: ReadingLanguage.english,
                  groupValue: _language,
                  onChanged: (v) => setState(() => _language = v!),
                ),
                RadioListTile<ReadingLanguage>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Urdu'),
                  value: ReadingLanguage.urdu,
                  groupValue: _language,
                  onChanged: (v) => setState(() => _language = v!),
                ),
                RadioListTile<ReadingLanguage>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Both'),
                  value: ReadingLanguage.both,
                  groupValue: _language,
                  onChanged: (v) => setState(() => _language = v!),
                ),
                const SizedBox(height: 16),
                Text('Preferred branch',
                    style: AppTypography.lora(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _branch,
                  items: const [
                    DropdownMenuItem(
                        value: 'COMSATS Main Library', child: Text('COMSATS Main Library')),
                  ],
                  onChanged: (v) => setState(() => _branch = v ?? _branch),
                ),
                const SizedBox(height: 24),
                Text('Font size',
                    style: AppTypography.lora(fontSize: 15, fontWeight: FontWeight.w600)),
                Slider(
                  value: FontSizeOption.values.indexOf(_fontSize).toDouble(),
                  min: 0,
                  max: 2,
                  divisions: 2,
                  label: _fontSize.name,
                  onChanged: (v) => setState(() => _fontSize = FontSizeOption.values[v.round()]),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Small', style: AppTypography.inter(fontSize: 11, color: ext.slate)),
                    Text('Medium', style: AppTypography.inter(fontSize: 11, color: ext.slate)),
                    Text('Large', style: AppTypography.inter(fontSize: 11, color: ext.slate)),
                  ],
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Save',
                  onPressed: () {
                    context.read<ProfileCubit>().savePersonalization(
                      preferredSubjects: _subjects,
                      readingLanguage: _language,
                      preferredBranch: _branch,
                      fontSize: _fontSize,
                    );
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Preferences saved')));
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}