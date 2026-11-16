import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:food_nav_demo/data/foods.dart';
import 'package:food_nav_demo/models/cart.dart';
import 'package:food_nav_demo/models/food.dart';
import 'package:food_nav_demo/utils/format.dart';
import 'package:food_nav_demo/widgets/current_url_bar.dart';
import 'package:food_nav_demo/widgets/food_image.dart';

class DetailScreen extends StatefulWidget {
  final String id;
  final Future<List<Food>> foodsFuture;
  final bool viewOnly;
  final int currentQuantity;

  const DetailScreen({
    super.key,
    required this.id,
    required this.foodsFuture,
    required this.viewOnly,
    this.currentQuantity = 0,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _qty = Cart.minQuantity;
  bool _allowPop = false;

  int get _currentQuantity =>
      widget.currentQuantity.clamp(0, Cart.maxQuantity).toInt();

  int get _maxAddable => Cart.maxQuantity - _currentQuantity;

  void _leaveToMenu(BuildContext context) {
    // [NAV] pop nếu màn được mở từ Thực đơn; go nếu vào thẳng bằng URL.
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed('menu');
    }
  }

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
    return FutureBuilder<List<Food>>(
      future: widget.foodsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
                title: const Text('Lỗi thực đơn'),
                bottom: const CurrentUrlBar()),
            body: Center(
                child: Text('Không tải được thực đơn: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Đang tải món'),
              bottom: const CurrentUrlBar(),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        return _buildFood(context, findFoodById(snapshot.data!, widget.id));
      },
    );
  }

  Widget _buildFood(BuildContext context, Food? food) {
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
                  // [NAV] quay lại màn trước, hoặc về Thực đơn nếu vào thẳng URL
                  onPressed: () => _leaveToMenu(context),
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
            if (!widget.viewOnly) ...[
              if (_currentQuantity > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Trong giỏ: $_currentQuantity/${Cart.maxQuantity}',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              if (_maxAddable > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.outlined(
                      icon: const Icon(Icons.remove),
                      onPressed: _qty > Cart.minQuantity
                          ? () => setState(() => _qty--)
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text('$_qty', style: textTheme.titleLarge),
                    ),
                    IconButton.outlined(
                      icon: const Icon(Icons.add),
                      onPressed: _qty < _maxAddable
                          ? () => setState(() => _qty++)
                          : null,
                    ),
                  ],
                )
              else
                Text(
                  'Món này đã đủ ${Cart.maxQuantity} phần trong giỏ.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
            ],
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: widget.viewOnly
                  ? () => _leaveToMenu(context)
                  : _maxAddable == 0
                      ? null
                      : () {
                          setState(() => _allowPop = true);
                          // [NAV] trả số lượng về Thực đơn
                          context.pop(_qty);
                        },
              child: Text(
                widget.viewOnly
                    ? 'Về thực đơn'
                    : _maxAddable == 0
                        ? 'Đã đạt tối đa ${Cart.maxQuantity} phần'
                        : 'Thêm vào giỏ – ${formatPrice(food.price * _qty)}',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
