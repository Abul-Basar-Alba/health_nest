class Validators {
  /// Validates an email address format.
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email cannot be empty.';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  /// Validates a password's length.
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password cannot be empty.';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  /// Validates that a name is not empty.
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name cannot be empty.';
    }
    return null;
  }

  /// Validates that a number field is not empty and is a positive number.
  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName cannot be empty.';
    }
    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return 'Please enter a valid $fieldName.';
    }
    return null;
  }
}
