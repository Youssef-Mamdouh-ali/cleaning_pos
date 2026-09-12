import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_pos/core/utils/validators.dart';

void main() {
  group('Validators.productName', () {
    test('يرفض القيمة الفارغة', () {
      expect(Validators.productName(''), isNotNull);
      expect(Validators.productName(null), isNotNull);
    });

    test('يقبل اسم صحيح', () {
      expect(Validators.productName('صابون سائل'), isNull);
    });
  });

  group('Validators.barcode', () {
    test('يرفض الباركود الفارغ', () {
      expect(Validators.barcode('  '), isNotNull);
    });

    test('يقبل باركود صحيح', () {
      expect(Validators.barcode('6221031200011'), isNull);
    });
  });

  group('Validators.price', () {
    test('يرفض نص مش رقم', () {
      expect(Validators.price('ابيض'), isNotNull);
    });

    test('يرفض رقم سالب', () {
      expect(Validators.price('-5'), isNotNull);
    });

    test('يقبل رقم صحيح موجب', () {
      expect(Validators.price('12.5'), isNull);
    });
  });

  group('Validators.quantity', () {
    test('يرفض رقم عشري', () {
      expect(Validators.quantity('3.5'), isNotNull);
    });

    test('يقبل رقم صحيح', () {
      expect(Validators.quantity('10'), isNull);
    });
  });

  group('Validators.optionalNumber', () {
    test('يقبل قيمة فارغة (اختياري)', () {
      expect(Validators.optionalNumber(''), isNull);
    });

    test('يرفض نص مش رقم لو مكتوب', () {
      expect(Validators.optionalNumber('غير رقم'), isNotNull);
    });
  });
}
