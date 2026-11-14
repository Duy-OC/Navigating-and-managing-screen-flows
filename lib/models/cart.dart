import 'package:food_nav_demo/models/cart_item.dart';
import 'package:food_nav_demo/models/food.dart';

class Cart {
  static const minQuantity = 1;
  static const maxQuantity = 10;

  final List<CartItem> items;

  const Cart([this.items = const []]);

  bool get isEmpty => items.isEmpty;

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice => items.fold(0, (sum, item) => sum + item.total);

  /// Thêm món; cộng dồn nếu đã có (giữ nguyên vị trí), ngược lại thêm vào cuối.
  Cart add(Food food, int quantity) {
    if (quantity < minQuantity || quantity > maxQuantity) {
      throw ArgumentError.value(
          quantity, 'quantity', 'phải nằm trong [$minQuantity, $maxQuantity]');
    }
    final newList = List<CartItem>.of(items);
    final index = newList.indexWhere((item) => item.food.id == food.id);
    if (index >= 0) {
      newList[index] =
          newList[index].copyWith(quantity: newList[index].quantity + quantity);
    } else {
      newList.add(CartItem(food, quantity));
    }
    return Cart(List.unmodifiable(newList));
  }

  int quantityOf(String foodId) {
    for (final item in items) {
      if (item.food.id == foodId) return item.quantity;
    }
    return 0;
  }

  Cart clear() => const Cart();
}
