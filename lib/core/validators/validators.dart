class Validators {
  Validators._();

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? mobileNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    final trimmed = value.trim();
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(trimmed)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? pincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pincode is required';
    }
    final trimmed = value.trim();
    if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(trimmed)) {
      return 'Enter a valid 6-digit pincode';
    }
    return null;
  }

  static String? gstNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'GST number is required';
    }
    final trimmed = value.trim().toUpperCase();
    // Standard GSTIN format: 22AAAAA0000A1Z5
    final pattern = RegExp(
      r'^\d{2}[A-Z]{5}\d{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
    );
    if (!pattern.hasMatch(trimmed)) {
      return 'Enter a valid 15-character GSTIN';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Include at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Include at least one number';
    }
    return null;
  }

  static String? giftCardCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Gift card code is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 8) {
      return 'Gift card code looks too short';
    }
    return null;
  }
}

