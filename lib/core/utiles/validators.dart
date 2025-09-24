class Validators {
  /// Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final cleaned = value.replaceAll(RegExp(r'\s+|-'), '');

    if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
      return 'Enter only digits';
    }

    if (cleaned.length < 10 || cleaned.length > 13) {
      return 'Phone number must be between 10 and 13 digits';
    }

    return null;
  }

  /// Name validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }

    // Allow letters and spaces only
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters';
    }

    return null; //
  }
}
