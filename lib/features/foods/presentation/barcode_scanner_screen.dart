import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../data/food_repository_provider.dart';
import '../domain/barcode_lookup_result.dart';
import '../domain/barcode_product.dart';
import '../domain/food.dart';
import 'custom_food_screen.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  late MobileScannerController _controller;
  bool _isProcessing = false;
  bool _hasConsent = true;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      autoStart: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConsentAndStart();
    });
  }

  Future<void> _checkConsentAndStart() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final hasConsented = prefs.getBool(AppConstants.prefHasConsentedBarcodeNetwork) ?? false;

    if (!hasConsented) {
      setState(() => _hasConsent = false);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);

      final agreed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.wifi_rounded, size: 36, color: AppColors.primary),
          title: Text(l10n.barcodeLookupConsentTitle),
          content: Text(l10n.barcodeLookupConsentDesc),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.confirm),
            ),
          ],
        ),
      );

      if (agreed == true) {
        await prefs.setBool(AppConstants.prefHasConsentedBarcodeNetwork, true);
        setState(() => _hasConsent = true);
        _controller.start();
      } else {
        if (mounted) context.pop();
      }
    } else {
      _controller.start();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull?.rawValue?.trim();
    if (barcode == null || barcode.isEmpty) return;

    setState(() => _isProcessing = true);
    await _controller.stop();

    if (!mounted) return;
    final l10n = AppLocalizations.of(context);

    // Show loading progress overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.searchingBarcode),
                const SizedBox(height: 6),
                Text(
                  barcode,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final service = ref.read(barcodeLookupServiceProvider);
    final result = await service.lookup(barcode);

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // dismiss loading dialog

    await _handleLookupResult(result, barcode);
  }

  Future<void> _handleLookupResult(BarcodeLookupResult result, String barcode) async {
    final l10n = AppLocalizations.of(context);

    switch (result) {
      case BarcodeLookupSuccess(product: final product):
        await _openCustomFoodEditor(product);
        break;

      case BarcodeLookupIncompleteNutrition(product: final product):
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.incompleteNutritionTitle),
            content: Text(
              '${l10n.incompleteNutritionDesc}\n\n'
              'Sản phẩm: "${product.displayName}"',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n.scanAgain),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l10n.continueText),
              ),
            ],
          ),
        );
        if (proceed == true) {
          await _openCustomFoodEditor(product);
        } else {
          _resumeScanning();
        }
        break;

      case BarcodeLookupNotFound():
        final action = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.barcodeNotFoundTitle),
            content: Text(l10n.barcodeNotFoundDesc),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop('scan_again'),
                child: Text(l10n.scanAgain),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop('manual'),
                child: Text(l10n.manualEntry),
              ),
            ],
          ),
        );
        if (action == 'manual') {
          await _openManualEntry(barcode: barcode);
        } else {
          _resumeScanning();
        }
        break;

      case BarcodeLookupNetworkError():
        final action = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.networkErrorTitle),
            content: Text(l10n.networkErrorDesc),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop('retry'),
                child: Text(l10n.scanAgain),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop('manual'),
                child: Text(l10n.manualEntry),
              ),
            ],
          ),
        );
        if (action == 'manual') {
          await _openManualEntry();
        } else {
          _resumeScanning();
        }
        break;

      case BarcodeLookupTimeout():
        final action = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.timeoutTitle),
            content: Text(l10n.timeoutDesc),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop('retry'),
                child: Text(l10n.scanAgain),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop('manual'),
                child: Text(l10n.manualEntry),
              ),
            ],
          ),
        );
        if (action == 'manual') {
          await _openManualEntry();
        } else {
          _resumeScanning();
        }
        break;
    }
  }

  Future<void> _openCustomFoodEditor(BarcodeProduct product) async {
    final Food? savedFood = await Navigator.of(context).push<Food>(
      MaterialPageRoute(
        builder: (_) => CustomFoodScreen(initialBarcodeProduct: product),
      ),
    );

    if (savedFood != null && mounted) {
      context.pop(savedFood);
    } else {
      _resumeScanning();
    }
  }

  Future<void> _openManualEntry({String? barcode}) async {
    final BarcodeProduct? initialProduct = barcode != null
        ? BarcodeProduct(
            barcode: barcode,
            name: '',
            kcalPer100g: 0,
            proteinPer100g: 0,
            carbPer100g: 0,
            fatPer100g: 0,
            defaultServingGrams: 100,
            servingLabel: 'portion',
          )
        : null;

    final Food? savedFood = await Navigator.of(context).push<Food>(
      MaterialPageRoute(
        builder: (_) => CustomFoodScreen(initialBarcodeProduct: initialProduct),
      ),
    );

    if (savedFood != null && mounted) {
      context.pop(savedFood);
    } else {
      _resumeScanning();
    }
  }

  void _resumeScanning() {
    if (mounted) {
      setState(() => _isProcessing = false);
      _controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanBarcode, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, child) {
              final isTorchOn = state.torchState == TorchState.on;
              return IconButton(
                icon: Icon(isTorchOn ? Icons.flash_on : Icons.flash_off),
                tooltip: 'Bật/tắt đèn',
                onPressed: () => _controller.toggleTorch(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded),
            tooltip: 'Lật camera',
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: !_hasConsent
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onBarcodeDetected,
                  errorBuilder: (context, error, child) {
                    return _buildErrorState(context, error, l10n);
                  },
                ),
                // Custom viewfinder overlay
                _buildViewfinderOverlay(context, l10n),
              ],
            ),
    );
  }

  Widget _buildViewfinderOverlay(BuildContext context, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = constraints.maxWidth * 0.75;
        final topOffset = (constraints.maxHeight - scanAreaSize) / 2.5;

        return Stack(
          children: [
            // Dark vignette background
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.55),
                BlendMode.srcOut,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.only(bottom: constraints.maxHeight * 0.15),
                      width: scanAreaSize,
                      height: scanAreaSize * 0.7,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Viewfinder border
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.only(bottom: constraints.maxHeight * 0.15),
                width: scanAreaSize,
                height: scanAreaSize * 0.7,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryLight, width: 2.5),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            // Hint text & manual entry button below viewfinder
            Positioned(
              left: 16,
              right: 16,
              top: topOffset + (scanAreaSize * 0.7) + 32,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.viewfinderHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.edit_note_rounded),
                    label: Text(l10n.manualEntry),
                    onPressed: () => _openManualEntry(),
                  ),
                ],
              ),
            ),
            // Attribution badge at bottom
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Text(
                l10n.openFoodFactsAttribution,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    MobileScannerException error,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.no_photography_rounded, size: 56, color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  l10n.cameraPermissionDeniedTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.cameraPermissionDeniedDesc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  icon: const Icon(Icons.edit_note_rounded),
                  label: Text(l10n.manualEntry),
                  onPressed: () => _openManualEntry(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
