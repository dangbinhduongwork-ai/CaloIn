import 'package:flutter_test/flutter_test.dart';
import 'package:caloin/core/utils/vietnamese_utils.dart';

void main() {
  group('VietnameseUtils', () {
    test('Normalizes standard precomposed Vietnamese text', () {
      expect(VietnameseUtils.normalize('Phở Bò'), 'pho bo');
      expect(VietnameseUtils.normalize('Đậu hũ'), 'dau hu');
      expect(VietnameseUtils.normalize('Bún chả Hà Nội'), 'bun cha ha noi');
      expect(VietnameseUtils.normalize('Cơm tấm sườn bì chả'), 'com tam suon bi cha');
    });

    test('Normalizes decomposed Unicode combining marks equivalent to precomposed', () {
      // "Phở Bò" using combining hook (U+0309) and combining grave (U+0300)
      const decomposedPho = 'Pho\u031b\u0309 Bo\u0300';
      const precomposedPho = 'Phở Bò';

      expect(VietnameseUtils.normalize(decomposedPho), 'pho bo');
      expect(VietnameseUtils.normalize(decomposedPho), equals(VietnameseUtils.normalize(precomposedPho)));

      // "Đậu" with combining marks
      const decomposedDau = '\u0110a\u0323u\u0302'; // Đ + a + dot below + u + circumflex
      expect(VietnameseUtils.normalize(decomposedDau), 'dau');
    });

    test('Handles extra whitespaces and punctuation', () {
      expect(VietnameseUtils.normalize('   Phở     bò   !?? '), 'pho bo');
      expect(VietnameseUtils.normalize('Cà-phê, sữa: đá.'), 'ca phe sua da');
    });

    test('Handles empty and blank strings', () {
      expect(VietnameseUtils.normalize(''), '');
      expect(VietnameseUtils.normalize('     '), '');
    });
  });
}
