class ValidationResult {
  const ValidationResult._({
    required this.isValid,
    this.errorCode,
    this.errorMessage,
  });

  final bool isValid;
  final String? errorCode;
  final String? errorMessage;

  static const ValidationResult valid = ValidationResult._(isValid: true);

  factory ValidationResult.invalid(String errorCode, [String? errorMessage]) {
    return ValidationResult._(
      isValid: false,
      errorCode: errorCode,
      errorMessage: errorMessage ?? errorCode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationResult &&
          runtimeType == other.runtimeType &&
          isValid == other.isValid &&
          errorCode == other.errorCode;

  @override
  int get hashCode => Object.hash(isValid, errorCode);

  @override
  String toString() => isValid ? 'ValidationResult(valid)' : 'ValidationResult(invalid: $errorCode)';
}
