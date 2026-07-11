import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../data/repositories/library_repository.dart';
import 'profile_state.dart';

/// Loads profile stats (books read / active holds / fines) from the
/// repository, and persists personalization + avatar in Hive — none
/// of this maps to a Koha resource beyond the underlying
/// checkouts/holds/fines calls already on the contract.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileState()) {
    _loadPersonalization();
    _loadAvatar();
  }

  final LibraryRepository _repository;

  static const String _prefsBoxName = 'settingsBox';
  static const String _personalizationKey = 'personalization';
  static const String _avatarBoxName = 'profileBox';
  static const String _avatarPathKey = 'avatarPath';

  Future<void> loadStats(int patronId) async {
    emit(state.copyWith(statsStatus: ProfileStatsStatus.loading, clearError: true));

    try {
      final results = await Future.wait([
        _repository.getBorrowingHistory(patronId),
        _repository.getHolds(patronId),
        _repository.getAccount(patronId),
      ]);

      final history = results[0] as List;
      final holds = results[1] as List;
      final fines = results[2] as List;

      final double outstanding = fines.fold<double>(
        0,
            (sum, f) => sum + (f as dynamic).amountoutstanding as double,
      );

      emit(state.copyWith(
        statsStatus: ProfileStatsStatus.loaded,
        booksReadCount: history.length,
        activeHoldsCount: holds.length,
        outstandingFines: outstanding,
      ));
    } on LibraryException catch (e) {
      emit(state.copyWith(statsStatus: ProfileStatsStatus.error, errorMessage: e.message));
    }
  }

  // ── Avatar ──────────────────────────────

  Future<void> _loadAvatar() async {
    final Box box = await Hive.openBox(_avatarBoxName);
    final String? path = box.get(_avatarPathKey) as String?;
    if (path != null) emit(state.copyWith(avatarPath: path));
  }

  Future<void> setAvatarPath(String path) async {
    emit(state.copyWith(avatarPath: path));
    final Box box = await Hive.openBox(_avatarBoxName);
    await box.put(_avatarPathKey, path);
  }

  // ── Personalization ──────────────────────────────

  Future<void> _loadPersonalization() async {
    final Box box = await Hive.openBox(_prefsBoxName);
    final Map? raw = box.get(_personalizationKey) as Map?;
    if (raw == null) return;

    final Map<String, dynamic> data = Map<String, dynamic>.from(raw);
    emit(state.copyWith(
      preferredSubjects: ((data['preferred_subjects'] as List?) ?? []).cast<String>().toSet(),
      readingLanguage: ReadingLanguage.values.firstWhere(
            (l) => l.name == data['reading_language'],
        orElse: () => ReadingLanguage.english,
      ),
      preferredBranch: data['preferred_branch'] as String? ?? 'COMSATS Main Library',
      fontSize: FontSizeOption.values.firstWhere(
            (f) => f.name == data['font_size'],
        orElse: () => FontSizeOption.medium,
      ),
    ));
  }

  Future<void> savePersonalization({
    required Set<String> preferredSubjects,
    required ReadingLanguage readingLanguage,
    required String preferredBranch,
    required FontSizeOption fontSize,
  }) async {
    emit(state.copyWith(
      preferredSubjects: preferredSubjects,
      readingLanguage: readingLanguage,
      preferredBranch: preferredBranch,
      fontSize: fontSize,
    ));

    final Box box = await Hive.openBox(_prefsBoxName);
    await box.put(_personalizationKey, {
      'preferred_subjects': preferredSubjects.toList(),
      'reading_language': readingLanguage.name,
      'preferred_branch': preferredBranch,
      'font_size': fontSize.name,
    });
  }
}