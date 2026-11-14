import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:food_nav_demo/data/foods.dart';
import 'package:food_nav_demo/models/cart.dart';
import 'package:food_nav_demo/utils/format.dart';
import 'package:food_nav_demo/widgets/current_url_bar.dart';
import 'package:food_nav_demo/widgets/food_image.dart';

class DetailScreen extends StatefulWidget {
  final String id;

  const DetailScreen({super.key, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _qty = Cart.minQuantity;
  bool _allowPop = false;

  Future<void> _onPopInvoked(bool didPop, int? result) async {
    if (didPop) return;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bỏ chọn món?'),
        content: Text('Bạn đã chọn $_qty phần nhưng chưa thêm vào giỏ.'),
        actions: [
          // [NAV] dialog cũng là route: pop kèm giá trị bằng Navigator gốc
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Ở lại')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Bỏ chọn')),
        ],
      ),
    );
    if (leave == true && mounted) {
      setState(() => _allowPop = true);
      // [NAV] rời màn không kèm dữ liệu → Thực đơn nhận null
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final food = findFoodById(widget.id);
    if (food == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Không tìm thấy'),
          bottom: const CurrentUrlBar(),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Không tìm thấy món "${widget.id}"',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  // [NAV] go về '/' (thay toàn bộ stack)
                  onPressed: () => context.go('/'),
                  child: const Text('Về thực đơn'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final textTheme = Theme.of(context).textTheme;
    return PopScope<int>(
      // [NAV] đã đổi số lượng mà chưa thêm → chặn Back để hỏi lại
      canPop: _qty == Cart.minQuantity || _allowPop,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        appBar: AppBar(
          title: Text(food.name),
          bottom: const CurrentUrlBar(),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FoodImage(food: food, height: 220, width: double.infinity),
            const SizedBox(height: 16),
            Text(food.name, style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              formatPrice(food.price),
              style: textTheme.titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(food.description, style: textTheme.bodyLarge),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.outlined(
                  icon: const Icon(Icons.remove),
                  onPressed: _qty > Cart.minQuantity ? () => setState(() => _qty--) : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('$_qty', style: textTheme.titleLarge),
                ),
                IconButton.outlined(
                  icon: const Icon(Icons.add),
                  onPressed: _qty < Cart.maxQuantity ? () => setState(() => _qty++) : null,
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: () {
                setState(() => _allowPop = true);
                // [NAV] trả số lượng về Thực đơn
                context.pop(_qty);
              },
              child:
                  Text('Thêm vào giỏ – ${formatPrice(food.price * _qty)}'),
            ),
          ),
        ),
      ),
    );
  }
}
