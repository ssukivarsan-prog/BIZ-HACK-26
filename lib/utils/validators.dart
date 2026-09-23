/// Reusable form field validators.
/// Return null = valid, non-null String = error message.
class AppValidators {
  AppValidators._();

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!re.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Enter a valid 10-digit phone number';
    return null;
  }

  static String? positiveNumber(String? value, {String field = 'Value'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    final n = double.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n <= 0) return '$field must be greater than 0';
    return null;
  }

  static String? nonNegativeNumber(String? value, {String field = 'Value'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    final n = double.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n < 0) return '$field cannot be negative';
    return null;
  }

  static String? minLength(String? value, int min, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    if (value.trim().length < min) return '$field must be at least $min characters';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }
}
