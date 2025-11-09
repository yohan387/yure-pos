class EmailMasker {
  static String maskEmail(String email) {
    if (!email.contains('@')) {
      return email;
    }

    final parts = email.split('@');
    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 1) {
      return email;
    }

    final firstChar = username[0];
    final maskedUsername = '$firstChar***';

    return '$maskedUsername@$domain';
  }
}
