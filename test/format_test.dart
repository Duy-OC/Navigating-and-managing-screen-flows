import 'package:flutter_test/flutter_test.dart';
import 'package:food_nav_demo/utils/format.dart';

void main() {
  test('formatPrice', () {
    expect(formatPrice(0), '0đ');
    expect(formatPrice(25000), '25.000đ');
    expect(formatPrice(1250000), '1.250.000đ');
  });
}
