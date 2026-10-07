import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';

class QuickAddScreen extends ConsumerWidget {
  const QuickAddScreen({this.initialMealType, super.key});

  final String? initialMealType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quickAddCalories),
      ),
      body: Center(
        child: Text(l10n.quickAddCalories),
      ),
    );
  }
}
