/// `120000` -> `120 000 so'm`
String formatSom(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return '${amount < 0 ? '-' : ''}$buffer so\'m';
}

String formatTime(DateTime dt) {
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

const _months = [
  'yanvar', 'fevral', 'mart', 'aprel', 'may', 'iyun',
  'iyul', 'avgust', 'sentabr', 'oktabr', 'noyabr', 'dekabr',
];

const _weekdays = [
  'dushanba', 'seshanba', 'chorshanba', 'payshanba', 'juma', 'shanba', 'yakshanba',
];

String formatDateLong(DateTime dt) {
  return '${dt.day}-${_months[dt.month - 1]}, ${_weekdays[dt.weekday - 1]}';
}

String formatDateShort(DateTime dt) {
  return '${dt.day}-${_months[dt.month - 1]}';
}

String weekdayShort(DateTime dt) {
  const short = ['Dush', 'Sesh', 'Chor', 'Pay', 'Jum', 'Shan', 'Yak'];
  return short[dt.weekday - 1];
}
