import 'package:food_nav_demo/models/food.dart';

class CartItem {
  final Food food;
  final int quantity;

  const CartItem(this.food, this.quantity);

  int get total => food.price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(food, quantity ?? this.quantity);
}
