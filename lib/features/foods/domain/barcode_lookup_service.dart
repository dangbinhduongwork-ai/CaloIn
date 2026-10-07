import 'barcode_lookup_result.dart';

abstract class BarcodeLookupService {
  Future<BarcodeLookupResult> lookup(String barcode);
}
