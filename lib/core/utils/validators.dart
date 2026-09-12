
class Validators {
  Validators._();

  static String? required(String? value, {String message = 'مطلوب'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? productName(String? value) {
    return required(value, message: 'اسم المنتج مطلوب');
  }

  static String? barcode(String? value) {
    return required(value, message: 'الباركود مطلوب');
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) return 'مطلوب';
    final parsed = double.tryParse(value);
    if (parsed == null) return 'رقم غير صحيح';
    if (parsed < 0) return 'السعر لا يمكن أن يكون سالبًا';
    return null;
  }

  static String? quantity(String? value) {
    if (value == null || value.trim().isEmpty) return 'مطلوب';
    final parsed = int.tryParse(value);
    if (parsed == null) return 'رقم صحيح مطلوب';
    if (parsed < 0) return 'الكمية لا يمكن أن تكون سالبة';
    return null;
  }

  static String? optionalNumber(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (double.tryParse(value) == null) return 'رقم غير صحيح';
    return null;
  }
}
