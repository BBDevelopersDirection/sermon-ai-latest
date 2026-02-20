extension StringExtensions on String {
  String toGmail() {
    // Remove all special characters and spaces, keep only alphanumeric
    final cleanStr = replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    
    // Append @gmail.com
    return '$cleanStr@gmail.com';
  }
}
