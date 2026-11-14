import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:food_nav_demo/data/foods.dart';
import 'package:food_nav_demo/models/cart_item.dart';
import 'package:food_nav_demo/models/food.dart';
import 'package:food_nav_demo/utils/format.dart';
import 'package:food_nav_demo/widgets/current_url_bar.dart';
import 'package:food_nav_demo/widgets/food_image.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<CartItem> _cart = [];

  int get _cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  Future<void> _openFood(Food food) async {
    // [NAV] push kèm id món trong URL, await để nhận số lượng trả về
    final qty = await context.push<int>('/food/${food.id}');
    if (!mounted || qty == null) return; // null = người dùng bấm Back, không thêm
    setState(() {
      final index = _cart.indexWhere((item) => item.food.id == food.id);
      if (index >= 0) {
        final old = _cart[index];
        _cart = List.of(_cart)..[index] = CartItem(food, old.quantity + qty);
      } else {
        _cart = [..._cart, CartItem(food, qty)];
      }
    });
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Đã thêm $qty ${food.name}')));
  }

  Future<void> _openCart() async {
    // [NAV] route có tên + truyền danh sách món qua extra, await để biết đã đặt hàng chưa
    final ordered =
        await context.pushNamed<bool>('cart', extra: List<CartItem>.of(_cart));
    if (!mounted || ordered != true) return;
    setState(() => _cart = []);
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Đặt hàng thành công')));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thực đơn'),
        bottom: const CurrentUrlBar(),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('$_cartCount'),
              isLabelVisible: _cartCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: _cart.isEmpty ? null : _openCart,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final food in foods)
            Card.outlined(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openFood(food),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      FoodImage(food: food, width: 88, height: 88),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(food.name, style: textTheme.titleMedium),
                            Text(
                              formatPrice(food.price),
                              style: textTheme.bodyMedium
                                  ?.copyWith(color: primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text('Demo Router API', style: textTheme.labelLarge),
          const SizedBox(height: 8),
          OutlinedButton(
            // [NAV] go: nhảy tới URL như mở liên kết từ ngoài app
            onPressed: () => context.go('/food/pho'),
            child: const Text('Mở thẳng /food/pho'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            // [NAV] go tới URL không có route → errorBuilder
            onPressed: () => context.go('/xyz'),
            child: const Text('Thử URL không tồn tại /xyz'),
          ),
        ],
      ),
    );
  }
}
