class MacroSplit {
  const MacroSplit({
    required this.proteinPct,
    required this.carbPct,
    required this.fatPct,
  });

  final int proteinPct;
  final int carbPct;
  final int fatPct;

  static const MacroSplit defaultSplit = MacroSplit(
    proteinPct: 20,
    carbPct: 50,
    fatPct: 30,
  );

  int get total => proteinPct + carbPct + fatPct;

  bool get isValid =>
      proteinPct >= 0 &&
      carbPct >= 0 &&
      fatPct >= 0 &&
      total == 100;

  MacroSplit copyWith({
    int? proteinPct,
    int? carbPct,
    int? fatPct,
  }) {
    return MacroSplit(
      proteinPct: proteinPct ?? this.proteinPct,
      carbPct: carbPct ?? this.carbPct,
      fatPct: fatPct ?? this.fatPct,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MacroSplit &&
          runtimeType == other.runtimeType &&
          proteinPct == other.proteinPct &&
          carbPct == other.carbPct &&
          fatPct == other.fatPct;

  @override
  int get hashCode => Object.hash(proteinPct, carbPct, fatPct);

  @override
  String toString() => 'MacroSplit(P: $proteinPct%, C: $carbPct%, F: $fatPct%)';
}
