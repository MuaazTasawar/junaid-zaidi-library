import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../data/models/patron.dart';
import '../../data/repositories/library_repository.dart';
import 'auth_state.dart';

/// Owns session state for the whole app: restores a saved session on
/// cold start (checked by [SplashScreen]), performs login/logout, and
/// exposes the current [Patron] (including whether they're staff) to
/// any screen that needs "who is logged in" without re-fetching.
///
/// Registered as a lazy singleton in `service_locator.dart` so the
/// session persists across the entire app lifetime, not just one
/// screen.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState.initial()) {
    _restoreSession();
  }

  final LibraryRepository _repository;

  static const String _boxName = 'authBox';
  static const String _patronIdKey = 'patronId';

  Future<void> _restoreSession() async {
    final Box box = await Hive.openBox(_boxName);
    final int? savedPatronId = box.get(_patronIdKey) as int?;

    if (savedPatronId == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
      return;
    }

    try {
      final Patron patron = await _repository.getPatron(savedPatronId);
      emit(state.copyWith(
        status:
        patron.isStaff ? AuthStatus.authenticatedStaff : AuthStatus.authenticatedPatron,
        patron: patron,
      ));
    } on LibraryException {
      await box.delete(_patronIdKey);
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> login({
    required String cardnumber,
    required String password,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      final Patron patron = await _repository.login(
        cardnumber: cardnumber,
        password: password,
      );

      final Box box = await Hive.openBox(_boxName);
      await box.put(_patronIdKey, patron.patronId);

      emit(state.copyWith(
        status:
        patron.isStaff ? AuthStatus.authenticatedStaff : AuthStatus.authenticatedPatron,
        patron: patron,
        isSubmitting: false,
      ));
    } on LibraryException catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    }
  }

  Future<void> logout() async {
    final Box box = await Hive.openBox(_boxName);
    await box.delete(_patronIdKey);

    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}