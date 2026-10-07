class VietnameseUtils {
  VietnameseUtils._();

  static const Map<String, String> _charMap = {
    // a
    'à': 'a', 'á': 'a', 'ạ': 'a', 'ả': 'a', 'ã': 'a',
    'â': 'a', 'ầ': 'a', 'ấ': 'a', 'ậ': 'a', 'ẩ': 'a', 'ẫ': 'a',
    'ă': 'a', 'ằ': 'a', 'ắ': 'a', 'ặ': 'a', 'ẳ': 'a', 'ẵ': 'a',
    // e
    'è': 'e', 'é': 'e', 'ẹ': 'e', 'ẻ': 'e', 'ẽ': 'e',
    'ê': 'e', 'ề': 'e', 'ế': 'e', 'ệ': 'e', 'ể': 'e', 'ễ': 'e',
    // i
    'ì': 'i', 'í': 'i', 'ị': 'i', 'ỉ': 'i', 'ĩ': 'i',
    // o
    'ò': 'o', 'ó': 'o', 'ọ': 'o', 'ỏ': 'o', 'õ': 'o',
    'ô': 'o', 'ồ': 'o', 'ố': 'o', 'ộ': 'o', 'ổ': 'o', 'ỗ': 'o',
    'ơ': 'o', 'ờ': 'o', 'ớ': 'o', 'ợ': 'o', 'ở': 'o', 'ỡ': 'o',
    // u
    'ù': 'u', 'ú': 'u', 'ụ': 'u', 'ủ': 'u', 'ũ': 'u',
    'ư': 'u', 'ừ': 'u', 'ứ': 'u', 'ự': 'u', 'ử': 'u', 'ữ': 'u',
    // y
    'ỳ': 'y', 'ý': 'y', 'ỵ': 'y', 'ỷ': 'y', 'ỹ': 'y',
    // d
    'đ': 'd',
  };

  // Combining diacritical marks regex (U+0300 to U+036F)
  static final RegExp _combiningMarksRegex = RegExp(r'[\u0300-\u036f]');
  // Non-alphanumeric and non-space characters regex (removes punctuation)
  static final RegExp _punctuationRegex = RegExp(r'[^\w\s]', unicode: true);
  // Multiple spaces regex
  static final RegExp _multipleSpacesRegex = RegExp(r'\s+');

  /// Normalizes Vietnamese string to lowercase unaccented text:
  /// - Converts to lowercase
  /// - Strips combining diacritical marks (U+0300 - U+036F)
  /// - Maps precomposed Vietnamese accented characters to plain letters
  /// - Converts 'đ' to 'd'
  /// - Removes punctuation
  /// - Collapses multiple whitespace into a single space and trims
  static String normalize(String text) {
    if (text.isEmpty) return '';

    String result = text.toLowerCase();

    // 1. Remove combining diacritical marks (decomposed form)
    result = result.replaceAll(_combiningMarksRegex, '');

    // 2. Map precomposed Vietnamese characters & 'đ'
    final sb = StringBuffer();
    for (int i = 0; i < result.length; i++) {
      final char = result[i];
      sb.write(_charMap[char] ?? char);
    }
    result = sb.toString();

    // 3. Remove punctuation / special characters (keep a-z, 0-9, and spaces)
    result = result.replaceAll(_punctuationRegex, ' ');

    // 4. Collapse whitespace and trim
    result = result.replaceAll(_multipleSpacesRegex, ' ').trim();

    return result;
  }
}
