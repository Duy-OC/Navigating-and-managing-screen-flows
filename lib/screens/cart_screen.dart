import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:food_nav_demo/models/cart.dart';
import 'package:food_nav_demo/state/cart_controller.dart';
import 'package:food_nav_demo/utils/format.dart';
import 'package:food_nav_demo/widgets/current_url_bar.dart';
import 'package:food_nav_demo/widgets/food_image.dart';

class CartScreen extends StatelessWidget {
  final Cart? cart;
  final CartController? cartController;

  const CartScreen({super.key, this.cart, this.cartController});

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
    if (ok != true || !context.mounted) return;

    // [NAV] xóa giỏ ở cấp app rồi trả true về Thực đơn.
    cartController?.clear();
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Đặt hàng thành công')));
    if (context.canPop()) {
      context.pop(true);
    } else {
      context.goNamed('menu');
    }
  }

  @override
  Widget build(BuildContext context) {
    // extra có thể bị mất khi mở thẳng bằng URL → dùng giỏ ở cấp app.
    final cart = this.cart ?? cartController?.cart;
    final appBar = AppBar(
      title: const Text('Giỏ hàng'),
      bottom: const CurrentUrlBar(),
    );

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
                  // [NAV] pop nếu có màn trước; go nếu vào thẳng bằng URL
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.goNamed('menu'),
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
                    children: [
                      Expanded(
                          child:
                              Text('Tổng cộng', style: textTheme.titleLarge)),
                      Flexible(
                          child: Text(formatPrice(total),
                              textAlign: TextAlign.end,
                              style: textTheme.titleLarge)),
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
