import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/data/settings_provider.dart';
import '../../settings/domain/settings_enums.dart';
import '../data/onboarding_draft_provider.dart';
import '../domain/profile_enums.dart';
import '../domain/profile_validator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({this.isEditing = false, super.key});

  final bool isEditing;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentStep = 0;

  // Controllers
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  // Local draft state
  late Gender _gender;
  late ActivityLevel _activityLevel;
  late Goal _goal;

  String? _ageError;
  String? _heightError;
  String? _weightError;
  bool _isUnder18 = false;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(onboardingDraftProvider);
    _gender = draft.gender;
    _activityLevel = draft.activityLevel;
    _goal = draft.goal;

    _ageController = TextEditingController(text: draft.age.toString());
    _heightController = TextEditingController(text: draft.heightCm.round().toString());
    _weightController = TextEditingController(text: draft.weightKg.toStringAsFixed(1));

    _validateAge();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _validateAge() {
    final age = int.tryParse(_ageController.text);
    final validation = ProfileValidator.validateAge(age);
    setState(() {
      _isUnder18 = validation.errorCode == 'underAge';
      _ageError = validation.isValid ? null : validation.errorMessage;
    });
  }

  void _validateStep2() {
    final settings = ref.read(settingsProvider);
    final isMetricWeight = settings.weightUnit.isKg;
    final isMetricHeight = settings.heightUnit.isCm;

    double? weightKg;
    final rawWeight = double.tryParse(_weightController.text);
    if (rawWeight != null) {
      weightKg = isMetricWeight ? rawWeight : UnitConverter.lbToKg(rawWeight);
    }

    double? heightCm;
    final rawHeight = double.tryParse(_heightController.text);
    if (rawHeight != null) {
      heightCm = isMetricHeight ? rawHeight : rawHeight * 2.54; // inch to cm
    }

    final weightVal = ProfileValidator.validateWeight(weightKg);
    final heightVal = ProfileValidator.validateHeight(heightCm);

    setState(() {
      _weightError = weightVal.isValid ? null : weightVal.errorMessage;
      _heightError = heightVal.isValid ? null : heightVal.errorMessage;
    });
  }

  bool get _isCurrentStepValid {
    if (_currentStep == 0) {
      final age = int.tryParse(_ageController.text);
      return ProfileValidator.validateAge(age).isValid && !_isUnder18;
    }
    if (_currentStep == 1) {
      final settings = ref.read(settingsProvider);
      final rawWeight = double.tryParse(_weightController.text);
      final rawHeight = double.tryParse(_heightController.text);
      if (rawWeight == null || rawHeight == null) return false;

      final weightKg = settings.weightUnit.isKg ? rawWeight : UnitConverter.lbToKg(rawWeight);
      final heightCm = settings.heightUnit.isCm ? rawHeight : rawHeight * 2.54;

      return ProfileValidator.validateWeight(weightKg).isValid &&
          ProfileValidator.validateHeight(heightCm).isValid;
    }
    return true; // Steps 2 and 3 are choice-based, always valid
  }

  void _toggleWeightUnit() {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final currentUnit = ref.read(settingsProvider).weightUnit;
    final val = double.tryParse(_weightController.text);

    if (val != null) {
      if (currentUnit.isKg) {
        // kg -> lb
        _weightController.text = UnitConverter.kgToLb(val).toStringAsFixed(1);
        settingsNotifier.setWeightUnit(WeightUnit.lb);
      } else {
        // lb -> kg
        _weightController.text = UnitConverter.lbToKg(val).toStringAsFixed(1);
        settingsNotifier.setWeightUnit(WeightUnit.kg);
      }
    } else {
      settingsNotifier.setWeightUnit(currentUnit.isKg ? WeightUnit.lb : WeightUnit.kg);
    }
    _validateStep2();
  }

  void _toggleHeightUnit() {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final currentUnit = ref.read(settingsProvider).heightUnit;
    final val = double.tryParse(_heightController.text);

    if (val != null) {
      if (currentUnit.isCm) {
        // cm -> inches
        _heightController.text = (val / 2.54).toStringAsFixed(1);
        settingsNotifier.setHeightUnit(HeightUnit.ftIn);
      } else {
        // inches -> cm
        _heightController.text = (val * 2.54).round().toString();
        settingsNotifier.setHeightUnit(HeightUnit.cm);
      }
    } else {
      settingsNotifier.setHeightUnit(currentUnit.isCm ? HeightUnit.ftIn : HeightUnit.cm);
    }
    _validateStep2();
  }

  void _onNext() {
    if (!_isCurrentStepValid) return;

    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      // Save to draft and navigate to summary
      final settings = ref.read(settingsProvider);
      final rawWeight = double.tryParse(_weightController.text) ?? 65.0;
      final rawHeight = double.tryParse(_heightController.text) ?? 170.0;

      final weightKg = settings.weightUnit.isKg ? rawWeight : UnitConverter.lbToKg(rawWeight);
      final heightCm = settings.heightUnit.isCm ? rawHeight : rawHeight * 2.54;
      final age = int.tryParse(_ageController.text) ?? 25;

      ref.read(onboardingDraftProvider.notifier).update((draft) {
        return draft.copyWith(
          gender: _gender,
          age: age,
          heightCm: heightCm,
          weightKg: weightKg,
          activityLevel: _activityLevel,
          goal: _goal,
        );
      });

      if (widget.isEditing) {
        context.push('/onboarding/summary?isEditing=true');
      } else {
        context.push('/onboarding/summary');
      }
    }
  }

  void _onBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _onBack,
              )
            : (widget.isEditing
                ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Progress bar
            LinearProgressIndicator(
              value: (_currentStep + 1) / 4,
              backgroundColor: AppColors.borderLight,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildCurrentStepContent(context),
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: FilledButton(
                onPressed: _isCurrentStepValid ? _onNext : null,
                child: Text(_currentStep < 3 ? l10n.continueText : l10n.done),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildStep1GenderAge(context);
      case 1:
        return _buildStep2HeightWeight(context);
      case 2:
        return _buildStep3Activity(context);
      case 3:
        return _buildStep4Goal(context);
      default:
        return const SizedBox.shrink();
    }
  }

  // --- Step 1: Gender & Age ---
  Widget _buildStep1GenderAge(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Thông tin cơ bản',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Giới tính và tuổi giúp tính mức tiêu hao năng lượng cơ bản (BMR).',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Gender Selector
        Text(l10n.gender, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(
                  Icons.male_rounded,
                  color: _gender.isMale ? Colors.white : AppColors.primary,
                ),
                label: Text(l10n.male),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _gender.isMale ? AppColors.primary : null,
                  foregroundColor: _gender.isMale ? Colors.white : null,
                  side: BorderSide(
                    color: _gender.isMale ? AppColors.primary : AppColors.borderLight,
                    width: 2,
                  ),
                ),
                onPressed: () => setState(() => _gender = Gender.male),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(
                  Icons.female_rounded,
                  color: _gender.isFemale ? Colors.white : Colors.pinkAccent,
                ),
                label: Text(l10n.female),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _gender.isFemale ? AppColors.primary : null,
                  foregroundColor: _gender.isFemale ? Colors.white : null,
                  side: BorderSide(
                    color: _gender.isFemale ? AppColors.primary : AppColors.borderLight,
                    width: 2,
                  ),
                ),
                onPressed: () => setState(() => _gender = Gender.female),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Age Input
        Text(l10n.age, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          onChanged: (_) => _validateAge(),
          decoration: InputDecoration(
            hintText: 'Nhập tuổi (18 - 100)',
            errorText: _isUnder18 ? null : _ageError,
          ),
        ),

        // Under 18 Gentle Warning Message
        if (_isUnder18) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade700),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.amber.shade800),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.under18Warning,
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // --- Step 2: Height & Weight ---
  Widget _buildStep2HeightWeight(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Chiều cao & Cân nặng',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Thông số thể trạng để ước tính diện tích cơ thể và tỷ lệ trao đổi chất.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Height
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.height, style: const TextStyle(fontWeight: FontWeight.w600)),
            TextButton.icon(
              icon: const Icon(Icons.swap_horiz_rounded, size: 16),
              label: Text(settings.heightUnit.isCm ? 'cm' : 'ft/in'),
              onPressed: _toggleHeightUnit,
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _heightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => _validateStep2(),
          decoration: InputDecoration(
            suffixText: settings.heightUnit.isCm ? 'cm' : 'inch',
            errorText: _heightError,
          ),
        ),
        const SizedBox(height: 24),

        // Weight
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.weight, style: const TextStyle(fontWeight: FontWeight.w600)),
            TextButton.icon(
              icon: const Icon(Icons.swap_horiz_rounded, size: 16),
              label: Text(settings.weightUnit.isKg ? 'kg' : 'lb'),
              onPressed: _toggleWeightUnit,
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => _validateStep2(),
          decoration: InputDecoration(
            suffixText: settings.weightUnit.isKg ? 'kg' : 'lb',
            errorText: _weightError,
          ),
        ),
      ],
    );
  }

  // --- Step 3: Activity Level ---
  Widget _buildStep3Activity(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final levels = [
      (ActivityLevel.sedentary, l10n.sedentary, 'Hệ số: 1.2'),
      (ActivityLevel.light, l10n.lightActivity, 'Hệ số: 1.375'),
      (ActivityLevel.moderate, l10n.moderateActivity, 'Hệ số: 1.55'),
      (ActivityLevel.veryActive, l10n.veryActive, 'Hệ số: 1.725'),
      (ActivityLevel.extraActive, l10n.extraActive, 'Hệ số: 1.9'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.activityLevel,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Chọn mức vận động phản ánh đúng thói quen sinh hoạt hằng tuần của bạn.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 20),

        ...levels.map((item) {
          final isSelected = _activityLevel == item.$1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => setState(() => _activityLevel = item.$1),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderLight,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected ? AppColors.primaryContainer.withOpacity(0.3) : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: isSelected ? AppColors.primary : Colors.grey,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$2,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.$3,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- Step 4: Goal ---
  Widget _buildStep4Goal(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final goals = [
      (Goal.maintain, l10n.maintainWeight, 'Giữ mức calo bằng đúng tổng năng lượng tiêu hao hằng ngày (TDEE).'),
      (Goal.lose, l10n.loseWeight, 'Mức thâm hụt vừa phải (-500 kcal/ngày) để giảm mỡ an toàn, bền vững.'),
      (Goal.gain, l10n.gainWeight, 'Mức thặng dư dinh dưỡng (+300 kcal/ngày) hỗ trợ phục hồi và phát triển.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.goal,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Mục tiêu sẽ định hình lượng calo nạp vào hàng ngày của bạn.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 20),

        ...goals.map((item) {
          final isSelected = _goal == item.$1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => setState(() => _goal = item.$1),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderLight,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected ? AppColors.primaryContainer.withOpacity(0.3) : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: isSelected ? AppColors.primary : Colors.grey,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$2,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.$3,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
