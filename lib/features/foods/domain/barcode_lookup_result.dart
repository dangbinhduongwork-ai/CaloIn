import 'barcode_product.dart';

sealed class BarcodeLookupResult {
  const BarcodeLookupResult();
}

class BarcodeLookupSuccess extends BarcodeLookupResult {
  const BarcodeLookupSuccess(this.product);
  final BarcodeProduct product;
}

class BarcodeLookupNotFound extends BarcodeLookupResult {
  const BarcodeLookupNotFound(this.barcode);
  final String barcode;
}

class BarcodeLookupIncompleteNutrition extends BarcodeLookupResult {
  const BarcodeLookupIncompleteNutrition(this.product);
  final BarcodeProduct product;
}

class BarcodeLookupNetworkError extends BarcodeLookupResult {
  const BarcodeLookupNetworkError(this.message);
  final String message;
}

class BarcodeLookupTimeout extends BarcodeLookupResult {
  const BarcodeLookupTimeout();
}
