/// Form field validators
class Validators {
  Validators._();

  /// Validate phone number (Indian format)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Remove spaces and special characters
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check if it starts with +91 or is 10 digits
    if (cleanNumber.startsWith('+91')) {
      if (cleanNumber.length != 13) {
        return 'Please enter a valid phone number';
      }
    } else if (cleanNumber.length != 10) {
      return 'Please enter a valid 10-digit phone number';
    }

    // Check if all characters are digits (after potential +)
    final digitsOnly = cleanNumber.replaceAll('+', '');
    if (!RegExp(r'^\d+$').hasMatch(digitsOnly)) {
      return 'Phone number should contain only digits';
    }

    return null;
  }

  /// Validate OTP
  static String? otp(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (value.length != length) {
      return 'Please enter a valid $length-digit OTP';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'OTP should contain only digits';
    }
    return null;
  }

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate name
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }

  /// Validate required field
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate bid amount
  static String? bidAmount(
    String? value, {
    required double minBid,
    required double currentBid,
    required double increment,
  }) {
    if (value == null || value.isEmpty) {
      return 'Please enter bid amount';
    }

    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount < minBid) {
      return 'Bid must be at least ${_formatCurrency(minBid)}';
    }

    final minimumValidBid = currentBid + increment;
    if (amount < minimumValidBid) {
      return 'Bid must be at least ${_formatCurrency(minimumValidBid)}';
    }

    return null;
  }

  /// Validate Aadhaar number
  static String? aadhaar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Aadhaar number is required';
    }
    final cleanNumber = value.replaceAll(' ', '');
    if (cleanNumber.length != 12) {
      return 'Aadhaar number must be 12 digits';
    }
    if (!RegExp(r'^\d{12}$').hasMatch(cleanNumber)) {
      return 'Aadhaar number should contain only digits';
    }
    return null;
  }

  /// Validate PAN number
  static String? pan(String? value) {
    if (value == null || value.isEmpty) {
      return 'PAN number is required';
    }
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value.toUpperCase())) {
      return 'Please enter a valid PAN number';
    }
    return null;
  }

  static String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }
}
