import 'package:equatable/equatable.dart';

enum ProfileStatsStatus { idle, loading, loaded, error }
enum ReadingLanguage { english, urdu, both }
enum FontSizeOption { small, medium, large }

class ProfileState extends Equatable {
  const ProfileState({
    this.statsStatus = ProfileStatsStatus.idle,
    this.booksReadCount = 0,
    this.activeHoldsCount = 0,
    this.outstandingFines = 0,
    this.errorMessage,
    this.avatarPath,
    this.preferredSubjects = const {},
    this.readingLanguage = ReadingLanguage.english,
    this.preferredBranch = 'COMSATS Main Library',
    this.fontSize = FontSizeOption.medium,
    this.darkModeToggleBusy = false,
  });

  final ProfileStatsStatus statsStatus;
  final int booksReadCount;
  final int activeHoldsCount;
  final double outstandingFines;
  final String? errorMessage;

  final String? avatarPath;
  final Set<String> preferredSubjects;
  final ReadingLanguage readingLanguage;
  final String preferredBranch;
  final FontSizeOption fontSize;
  final bool darkModeToggleBusy;

  ProfileState copyWith({
    ProfileStatsStatus? statsStatus,
    int? booksReadCount,
    int? activeHoldsCount,
    double? outstandingFines,
    String? errorMessage,
    bool clearError = false,
    String? avatarPath,
    Set<String>? preferredSubjects,
    ReadingLanguage? readingLanguage,
    String? preferredBranch,
    FontSizeOption? fontSize,
    bool? darkModeToggleBusy,
  }) {
    return ProfileState(
      statsStatus: statsStatus ?? this.statsStatus,
      booksReadCount: booksReadCount ?? this.booksReadCount,
      activeHoldsCount: activeHoldsCount ?? this.activeHoldsCount,
      outstandingFines: outstandingFines ?? this.outstandingFines,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      avatarPath: avatarPath ?? this.avatarPath,
      preferredSubjects: preferredSubjects ?? this.preferredSubjects,
      readingLanguage: readingLanguage ?? this.readingLanguage,
      preferredBranch: preferredBranch ?? this.preferredBranch,
      fontSize: fontSize ?? this.fontSize,
      darkModeToggleBusy: darkModeToggleBusy ?? this.darkModeToggleBusy,
    );
  }

  @override
  List<Object?> get props => [
    statsStatus,
    booksReadCount,
    activeHoldsCount,
    outstandingFines,
    errorMessage,
    avatarPath,
    preferredSubjects,
    readingLanguage,
    preferredBranch,
    fontSize,
    darkModeToggleBusy,
  ];
}