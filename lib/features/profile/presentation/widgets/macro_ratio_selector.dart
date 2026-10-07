import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/macro_calculator.dart';
import '../../domain/macro_split.dart';

enum MacroPreset {
  balanced(MacroSplit(proteinPct: 20, carbPct: 50, fatPct: 30)),
  highProtein(MacroSplit(proteinPct: 30, carbPct: 40, fatPct: 30)),
  lowCarb(MacroSplit(proteinPct: 25, carbPct: 35, fatPct: 40)),
  custom(null);

  const MacroPreset(this.split);
  final MacroSplit? split;
}

class MacroRatioSelector extends StatefulWidget {
  const MacroRatioSelector({
    required this.targetKcal,
    required this.initialSplit,
    required this.onSplitChanged,
    super.key,
  });

  final int targetKcal;
  final MacroSplit initialSplit;
  final ValueChanged<MacroSplit> onSplitChanged;

  @override
  State<MacroRatioSelector> createState() => _MacroRatioSelectorState();
}

class _MacroRatioSelectorState extends State<MacroRatioSelector> {
  late MacroSplit _currentSplit;
  late MacroPreset _selectedPreset;

  late TextEditingController _proteinController;
  late TextEditingController _carbController;
  late TextEditingController _fatController;

  @override
  void initState() {
    super.initState();
    _currentSplit = widget.initialSplit;
    _selectedPreset = _detectPreset(widget.initialSplit);

    _proteinController = TextEditingController(text: _currentSplit.proteinPct.toString());
    _carbController = TextEditingController(text: _currentSplit.carbPct.toString());
    _fatController = TextEditingController(text: _currentSplit.fatPct.toString());
  }

  MacroPreset _detectPreset(MacroSplit split) {
    if (split == MacroPreset.balanced.split) return MacroPreset.balanced;
    if (split == MacroPreset.highProtein.split) return MacroPreset.highProtein;
    if (split == MacroPreset.lowCarb.split) return MacroPreset.lowCarb;
    return MacroPreset.custom;
  }

  @override
  void didUpdateWidget(covariant MacroRatioSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSplit != widget.initialSplit) {
      _currentSplit = widget.initialSplit;
      _selectedPreset = _detectPreset(widget.initialSplit);
      _proteinController.text = _currentSplit.proteinPct.toString();
      _carbController.text = _currentSplit.carbPct.toString();
      _fatController.text = _currentSplit.fatPct.toString();
    }
  }

  @override
  void dispose() {
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _selectPreset(MacroPreset preset) {
    if (preset == MacroPreset.custom) {
      setState(() {
        _selectedPreset = MacroPreset.custom;
      });
      return;
    }

    final newSplit = preset.split!;
    setState(() {
      _selectedPreset = preset;
      _currentSplit = newSplit;
      _proteinController.text = newSplit.proteinPct.toString();
      _carbController.text = newSplit.carbPct.toString();
      _fatController.text = newSplit.fatPct.toString();
    });
    widget.onSplitChanged(newSplit);
  }

  void _onCustomFieldChanged() {
    final p = int.tryParse(_proteinController.text) ?? 0;
    final c = int.tryParse(_carbController.text) ?? 0;
    final f = int.tryParse(_fatController.text) ?? 0;

    final newSplit = MacroSplit(proteinPct: p, carbPct: c, fatPct: f);
    setState(() {
      _currentSplit = newSplit;
    });

    if (newSplit.isValid) {
      widget.onSplitChanged(newSplit);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final grams = MacroCalculator.calculateGrams(
      targetKcal: widget.targetKcal,
      macroSplit: _currentSplit,
    );
    final totalPct = _currentSplit.total;
    final isTotalValid = totalPct == 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Preset Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPresetChip('Cân bằng (20/50/30)', MacroPreset.balanced),
              const SizedBox(width: 8),
              _buildPresetChip('Nhiều đạm (30/40/30)', MacroPreset.highProtein),
              const SizedBox(width: 8),
              _buildPresetChip('Ít tinh bột (25/35/40)', MacroPreset.lowCarb),
              const SizedBox(width: 8),
              _buildPresetChip('Tùy chỉnh', MacroPreset.custom),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Custom inputs if custom or fields
        if (_selectedPreset == MacroPreset.custom) ...[
          Row(
            children: [
              Expanded(
                child: _buildInputColumn('Đạm (%)', _proteinController, AppColors.protein),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInputColumn('Carb (%)', _carbController, AppColors.carb),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInputColumn('Béo (%)', _fatController, AppColors.fat),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!isTotalValid)
            Text(
              'Tổng tỉ lệ phải bằng 100% (Hiện tại: $totalPct%)',
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 12),
        ],

        // Grams breakdown display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isTotalValid ? AppColors.borderLight : Colors.redAccent.withOpacity(0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientStat(
                'Đạm',
                '${_currentSplit.proteinPct}%',
                AppFormatters.formatMacroWithUnit(grams.proteinGrams),
                AppColors.protein,
              ),
              _buildNutrientStat(
                'Carb',
                '${_currentSplit.carbPct}%',
                AppFormatters.formatMacroWithUnit(grams.carbGrams),
                AppColors.carb,
              ),
              _buildNutrientStat(
                'Béo',
                '${_currentSplit.fatPct}%',
                AppFormatters.formatMacroWithUnit(grams.fatGrams),
                AppColors.fat,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, MacroPreset preset) {
    final isSelected = _selectedPreset == preset;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _selectPreset(preset),
      selectedColor: AppColors.primaryContainer,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        color: isSelected ? AppColors.primaryDark : null,
      ),
    );
  }

  Widget _buildInputColumn(String title, TextEditingController controller, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (_) => _onCustomFieldChanged(),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            suffixText: '%',
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientStat(String title, String pct, String grams, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          grams,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Text(
          pct,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
