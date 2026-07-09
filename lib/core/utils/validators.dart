/// Shared form-field validators, used by `AppTextField.validator`
/// across LoginScreen, ForgotPasswordScreen, PlaceHoldSheet, etc.
/// Keeping these out of widgets satisfies Golden Rule #2 (no
/// business logic in widgets).
class Validators {
  const Validators._();

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Library card number: required, non-empty after trimming.
  static String? cardNumber(String? value) {
    return required(value, fieldName: 'Card number');
  }

  /// Password: required, minimum 4 characters (per LoginScreen spec).
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 4) return 'Password must be at least 4 characters';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final RegExp emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }
}