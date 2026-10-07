import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../domain/barcode_lookup_result.dart';
import '../domain/barcode_lookup_service.dart';
import '../domain/barcode_product.dart';

class OpenFoodFactsLookupServiceImpl implements BarcodeLookupService {
  OpenFoodFactsLookupServiceImpl({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _userAgent =
      'CaloIn - Flutter - Version 1.0.0 - https://github.com/dangbinhduongwork-ai/CaloIn';

  @override
  Future<BarcodeLookupResult> lookup(String barcode) async {
    final cleanBarcode = barcode.trim();
    if (cleanBarcode.isEmpty) {
      return const BarcodeLookupNotFound('');
    }

    final uri = Uri.parse(
      'https://world.openfoodfacts.org/api/v2/product/$cleanBarcode.json'
      '?fields=code,product_name,product_name_vi,product_name_en,brands,quantity,serving_size,serving_quantity,nutriments,image_front_url',
    );

    try {
      final response = await _client.get(
        uri,
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) {
        return BarcodeLookupNotFound(cleanBarcode);
      }

      if (response.statusCode != 200) {
        return BarcodeLookupNetworkError('Máy chủ phản hồi mã lỗi ${response.statusCode}');
      }

      final Map<String, dynamic> jsonBody = json.decode(response.body) as Map<String, dynamic>;
      final status = jsonBody['status'] as int? ?? 0;
      final productMap = jsonBody['product'] as Map<String, dynamic>?;

      if (status == 0 || productMap == null) {
        return BarcodeLookupNotFound(cleanBarcode);
      }

      return _parseProduct(cleanBarcode, productMap);
    } on TimeoutException {
      return const BarcodeLookupTimeout();
    } on SocketException catch (e) {
      return BarcodeLookupNetworkError('Không thể kết nối Internet: ${e.message}');
    } on http.ClientException catch (e) {
      return BarcodeLookupNetworkError('Lỗi mạng: ${e.message}');
    } catch (e) {
      return BarcodeLookupNetworkError('Đã xảy ra lỗi không xác định: $e');
    }
  }

  BarcodeLookupResult _parseProduct(String barcode, Map<String, dynamic> map) {
    // 1. Product Name (Prioritize Vietnamese > General name > English)
    final nameVi = (map['product_name_vi'] as String?)?.trim();
    final nameGeneral = (map['product_name'] as String?)?.trim();
    final nameEn = (map['product_name_en'] as String?)?.trim();

    String name = 'Sản phẩm $barcode';
    if (nameVi != null && nameVi.isNotEmpty) {
      name = nameVi;
    } else if (nameGeneral != null && nameGeneral.isNotEmpty) {
      name = nameGeneral;
    } else if (nameEn != null && nameEn.isNotEmpty) {
      name = nameEn;
    }

    // 2. Brand
    final brand = (map['brands'] as String?)?.trim();

    // 3. Nutriments
    final nutriments = map['nutriments'] as Map<String, dynamic>? ?? {};

    double kcalPer100g = _extractDouble(nutriments, ['energy-kcal_100g', 'energy-kcal', 'energy-kcal_value']);

    // If kcal is missing or 0, attempt conversion from energy_100g (kJ)
    if (kcalPer100g <= 0) {
      final energyKj = _extractDouble(nutriments, ['energy_100g', 'energy']);
      if (energyKj > 0) {
        kcalPer100g = energyKj / 4.184; // 1 kcal = 4.184 kJ
      }
    }

    final proteinPer100g = _extractDouble(nutriments, ['proteins_100g', 'proteins']);
    final carbPer100g = _extractDouble(nutriments, ['carbohydrates_100g', 'carbohydrates']);
    final fatPer100g = _extractDouble(nutriments, ['fat_100g', 'fat']);

    // 4. Serving Size & Quantity
    double servingGrams = _extractDouble(map, ['serving_quantity']);
    final servingSizeStr = (map['serving_size'] as String?)?.trim() ?? '';

    if (servingGrams <= 0 && servingSizeStr.isNotEmpty) {
      servingGrams = _parseGramsFromString(servingSizeStr);
    }
    if (servingGrams <= 0) {
      servingGrams = 100.0;
    }

    String servingLabel = 'portion';
    if (servingSizeStr.toLowerCase().contains('bát') || servingSizeStr.toLowerCase().contains('tô')) {
      servingLabel = 'bowl';
    } else if (servingSizeStr.toLowerCase().contains('hộp') || servingSizeStr.toLowerCase().contains('lon')) {
      servingLabel = 'can';
    } else if (servingSizeStr.toLowerCase().contains('ly') || servingSizeStr.toLowerCase().contains('cốc')) {
      servingLabel = 'cup';
    } else if (servingSizeStr.toLowerCase().contains('gói')) {
      servingLabel = 'portion';
    }

    // 5. Image URL
    final imageUrl = map['image_front_url'] as String?;

    // Check completeness
    final hasNutrition = kcalPer100g > 0 || proteinPer100g > 0 || carbPer100g > 0 || fatPer100g > 0;

    final product = BarcodeProduct(
      barcode: barcode,
      name: name,
      brand: brand,
      kcalPer100g: double.parse(kcalPer100g.toStringAsFixed(1)),
      proteinPer100g: double.parse(proteinPer100g.toStringAsFixed(1)),
      carbPer100g: double.parse(carbPer100g.toStringAsFixed(1)),
      fatPer100g: double.parse(fatPer100g.toStringAsFixed(1)),
      defaultServingGrams: double.parse(servingGrams.toStringAsFixed(1)),
      servingLabel: servingLabel,
      imageUrl: imageUrl,
      hasCompleteNutrition: hasNutrition,
    );

    if (!hasNutrition) {
      return BarcodeLookupIncompleteNutrition(product);
    }

    return BarcodeLookupSuccess(product);
  }

  double _extractDouble(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final val = map[key];
      if (val is num) return val.toDouble();
      if (val is String) {
        final parsed = double.tryParse(val);
        if (parsed != null) return parsed;
      }
    }
    return 0.0;
  }

  double _parseGramsFromString(String str) {
    final regex = RegExp(r'(\d+(?:[.,]\d+)?)\s*(?:g|ml|gam)\b', caseSensitive: false);
    final match = regex.firstMatch(str);
    if (match != null) {
      final numStr = match.group(1)!.replaceAll(',', '.');
      return double.tryParse(numStr) ?? 100.0;
    }
    return 100.0;
  }
}
