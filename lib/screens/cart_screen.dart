import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:food_nav_demo/models/cart.dart';
import 'package:food_nav_demo/utils/format.dart';
import 'package:food_nav_demo/widgets/current_url_bar.dart';
import 'package:food_nav_demo/widgets/food_image.dart';

class CartScreen extends StatelessWidget {
  final Cart? cart;

  const CartScreen({super.key, this.cart});

  Future<void> _order(BuildContext context, int total) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đặt hàng?'),
        content: Text('Tổng cộng ${formatPrice(total)}'),
        actions: [
          // [NAV] dialog là route của Navigator gốc: pop kèm giá trị
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Đặt hàng')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      // [NAV] trả true về Thực đơn để xóa giỏ và báo thành công
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = this.cart; // biến cục bộ để Dart promote kiểu non-null
    final appBar = AppBar(
      title: const Text('Giỏ hàng'),
      bottom: const CurrentUrlBar(),
    );

    // [NAV] extra bị mất khi mở thẳng bằng URL → cart = null
    if (cart == null || cart.isEmpty) {
      return Scaffold(
        appBar: appBar,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Giỏ hàng trống'),
                const SizedBox(height: 16),
                FilledButton(
                  // [NAV] pop: đóng màn hiện tại, quay về màn bên dưới
                  onPressed: () => context.pop(),
                  child: const Text('Về thực đơn'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final total = cart.totalPrice;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                for (final item in cart.items)
                  ListTile(
                    leading: FoodImage(food: item.food, width: 56, height: 56),
                    title: Text(item.food.name),
                    subtitle: Text(
                        '${formatPrice(item.food.price)} × ${item.quantity}'),
                    trailing: Text(formatPrice(item.total)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tổng cộng', style: textTheme.titleLarge),
                      Text(formatPrice(total), style: textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _order(context, total),
                      child: const Text('Đặt hàng'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
