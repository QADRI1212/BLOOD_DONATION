extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  String get titleCase {
    if (isEmpty) return this;
    final words = split(' ');
    return words
        .map(
          (word) => word.length > 2
              ? word.capitalize
              : word.toLowerCase(),
        )
        .join(' ');
  }

  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegex.hasMatch(this);
  }

  bool get isValidPhone {
    final phoneRegex = RegExp(r'^\+?[\d\s\-()]{10,15}$');
    return phoneRegex.hasMatch(this);
  }

  bool get isValidPassword {
    return length >= 8 &&
        contains(RegExp(r'[A-Z]')) &&
        contains(RegExp(r'[a-z]')) &&
        contains(RegExp(r'[0-9]'));
  }

  String get initials {
    if (isEmpty) return '';
    final words = trim().split(' ');
    if (words.length >= 2) {
      return '${words.first[0]}${words.last[0]}'.toUpperCase();
    }
    return this[0].toUpperCase();
  }

  String toBloodGroup() {
    return toUpperCase().replaceAll(RegExp(r'\s'), '');
  }
}
