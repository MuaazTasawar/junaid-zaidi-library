import 'package:equatable/equatable.dart';

import '../../data/models/patron.dart';

enum AuthStatus {
  /// Splash is still checking Hive for a saved session.
  unknown,
  unauthenticated,
  authenticatedPatron,
  authenticatedStaff,
}

class AuthState extends Equatable {
  const AuthState({
    required this.status,
    this.patron,
    this.isSubmitting = false,
    this.errorMessage,
  });

  const AuthState.initial() : this(status: AuthStatus.unknown);

  final AuthStatus status;
  final Patron? patron;
  final bool isSubmitting;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    Patron? patron,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      patron: patron ?? this.patron,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, patron, isSubmitting, errorMessage];
}