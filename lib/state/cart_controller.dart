import 'package:flutter/foundation.dart';
import 'package:food_nav_demo/models/cart.dart';
import 'package:food_nav_demo/models/food.dart';

/// Giữ giỏ hàng ở cấp ứng dụng để state không mất khi route bị dựng lại.
class CartController extends ChangeNotifier {
  CartController([Cart initial = const Cart()]) : _cart = initial;

  Cart _cart;

  Cart get cart => _cart;

  bool canAdd(String foodId, int quantity) => _cart.canAdd(foodId, quantity);

  void add(Food food, int quantity) {
    _cart = _cart.add(food, quantity);
    notifyListeners();
  }

  void clear() {
    if (_cart.isEmpty) return;
    _cart = const Cart();
    notifyListeners();
  }
}
