import 'package:flutter_test/flutter_test.dart';
import 'package:food_nav_demo/data/foods.dart';
import 'package:food_nav_demo/models/cart.dart';
import 'package:food_nav_demo/models/cart_item.dart';
import 'package:food_nav_demo/models/food.dart';
import 'package:food_nav_demo/state/cart_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Food banhMi;
  late Food pho;

  setUpAll(() async {
    final foods = await loadFoods();
    banhMi = findFoodById(foods, 'banh-mi')!;
    pho = findFoodById(foods, 'pho')!;
  });

  test('giỏ rỗng', () {
    const cart = Cart();
    expect(cart.isEmpty, isTrue);
    expect(cart.totalQuantity, 0);
    expect(cart.totalPrice, 0);
  });

  test('add một món', () {
    final cart = const Cart().add(banhMi, 2);
    expect(cart.items, hasLength(1));
    expect(cart.totalQuantity, 2);
    expect(cart.totalPrice, 50000);
  });

  test('add cùng món thì cộng dồn', () {
    final cart = const Cart().add(banhMi, 2).add(banhMi, 1);
    expect(cart.items, hasLength(1));
    expect(cart.quantityOf('banh-mi'), 3);
  });

  test('add hai món khác nhau', () {
    final cart = const Cart().add(banhMi, 1).add(pho, 2);
    expect(cart.items, hasLength(2));
    expect(cart.totalPrice, 25000 + 90000);
  });

  test('số lượng ngoài khoảng 1..10 ném ArgumentError', () {
    expect(() => const Cart().add(banhMi, 0), throwsArgumentError);
    expect(() => const Cart().add(banhMi, 11), throwsArgumentError);
  });

  test('canAdd chặn tổng số lượng mỗi món vượt quá 10', () {
    final cart = const Cart().add(banhMi, 9);
    expect(cart.canAdd('banh-mi', 1), isTrue);
    expect(cart.canAdd('banh-mi', 2), isFalse);
    expect(cart.canAdd('pho', 10), isTrue);
    expect(() => cart.add(banhMi, 2), throwsArgumentError);
  });

  test('CartController giữ state và thông báo thay đổi', () {
    final controller = CartController();
    var notifications = 0;
    controller.addListener(() => notifications++);

    controller.add(banhMi, 2);
    expect(controller.cart.totalQuantity, 2);
    expect(controller.canAdd('banh-mi', 8), isTrue);
    expect(controller.canAdd('banh-mi', 9), isFalse);
    expect(notifications, 1);

    controller.clear();
    expect(controller.cart.isEmpty, isTrue);
    expect(notifications, 2);
  });

  test('Cart bất biến', () {
    const a = Cart();
    final b = a.add(banhMi, 1);
    expect(a.isEmpty, isTrue);
    expect(() => b.items.add(CartItem(banhMi, 1)), throwsUnsupportedError);
  });

  test('clear làm giỏ rỗng', () {
    final cart = const Cart().add(banhMi, 2).clear();
    expect(cart.isEmpty, isTrue);
  });

  test('CartItem.copyWith đổi số lượng và tính lại total', () {
    final item = CartItem(banhMi, 1).copyWith(quantity: 3);
    expect(item.quantity, 3);
    expect(item.total, 75000);
    expect(item.food, banhMi);
  });
}
