import 'package:flutter/services.dart';

/// O'zbekiston telefon raqami uchun kiritish formatlagichi:
/// foydalanuvchi faqat 9 ta raqamni kiritadi, ular avtomatik
/// `(##) ### ## ##` ko'rinishiga keladi. Mamlakat kodi (`+998`)
/// maydonning `prefixText`ida alohida, doimiy ko'rsatiladi —
/// controller faqat mahalliy 9 ta raqamni saqlaydi.
class UzPhoneInputFormatter extends TextInputFormatter {
  static const int _digitCount = 9;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > _digitCount ? digits.substring(0, _digitCount) : digits;

    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i == 0) buffer.write('(');
      buffer.write(limited[i]);
      if (i == 1) buffer.write(') ');
      if (i == 4) buffer.write(' ');
      if (i == 6) buffer.write(' ');
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// `(90) 123 45 67` -> `+998901234567`. To'liq bo'lmasa `null`.
String? uzPhoneToE164(String formatted) {
  final digits = formatted.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 9) return null;
  return '+998$digits';
}
