/// 25000 -> "25.000đ"
String formatPrice(int vnd) {
  final digits = vnd.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  final sign = vnd < 0 ? '-' : '';
  return '$sign${buffer.toString()}đ';
}
