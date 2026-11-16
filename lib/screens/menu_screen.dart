import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:food_nav_demo/models/cart.dart';
import 'package:food_nav_demo/models/food.dart';
import 'package:food_nav_demo/models/food_route_args.dart';
import 'package:food_nav_demo/screens/about_screen.dart';
import 'package:food_nav_demo/state/cart_controller.dart';
import 'package:food_nav_demo/utils/format.dart';
import 'package:food_nav_demo/widgets/current_url_bar.dart';
import 'package:food_nav_demo/widgets/food_image.dart';

class MenuScreen extends StatefulWidget {
  final Future<List<Food>> foodsFuture;
  final CartController cartController;

  const MenuScreen({
    super.key,
    required this.foodsFuture,
    required this.cartController,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  DateTime? _lastBackPressed;
  final TextEditingController _pathController = TextEditingController();
  String? _pathError;

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  void _goToPath() {
    final path = _pathController.text.trim();
    final uri = Uri.tryParse(path);
    String? error;
    if (path.isEmpty) {
      error = 'Vui lòng nhập đường dẫn';
    } else if (!path.startsWith('/')) {
      error = 'Đường dẫn phải bắt đầu bằng `/`';
    } else if (path.startsWith('//') ||
        path.contains('\\') ||
        uri == null ||
        uri.hasAuthority ||
        uri.hasScheme) {
      error = 'Chỉ nhập đường dẫn nội bộ của app';
    }
    if (error != null) {
      setState(() => _pathError = error);
      return;
    }
    FocusScope.of(context).unfocus();
    context.go(path);
  }

  Future<void> _openFood(Food food) async {
    _lastBackPressed = null;
    final cart = widget.cartController.cart;
    // [NAV] named route + path parameter + tham số có kiểu qua extra
    final qty = await context.pushNamed<int>(
      'food',
      pathParameters: {'id': food.id},
      extra: FoodRouteArgs(
        selectable: true,
        currentQuantity: cart.quantityOf(food.id),
      ),
    );
    if (!mounted ||
        qty == null ||
        qty < Cart.minQuantity ||
        qty > Cart.maxQuantity) {
      return;
    }
    if (!widget.cartController.canAdd(food.id, qty)) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Mỗi món tối đa ${Cart.maxQuantity} phần. '
              'Giỏ đang có ${widget.cartController.cart.quantityOf(food.id)}.',
            ),
          ),
        );
      return;
    }
    widget.cartController.add(food, qty);
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Đã thêm $qty ${food.name}')));
  }

  Future<void> _openCart() async {
    _lastBackPressed = null;
    // [NAV] route có tên + truyền object Cart qua extra, await để biết đã đặt hàng chưa
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    final ordered = await context.pushNamed<bool>(
      'cart',
      extra: widget.cartController.cart,
    );
    if (!mounted || ordered != true) return;
    // CartScreen đã xóa controller; gọi lại cho chắc nếu màn được dùng độc lập.
    widget.cartController.clear();
  }

  Future<void> _openAbout() async {
    _lastBackPressed = null;
    // [NAV] Navigator 1.0: push một MaterialPageRoute và chờ kết quả pop.
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const AboutScreen()),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message ?? 'Đã đóng màn Giới thiệu')),
      );
  }

  void _onRootPop(bool didPop, Object? result) {
    if (didPop) return;

    final now = DateTime.now();
    final last = _lastBackPressed;
    if (last == null || now.difference(last) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Nhấn Back lần nữa để thoát')),
        );
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;
    return PopScope(
      // [NAV] Back ở màn gốc: nhấn lần đầu chỉ nhắc, lần thứ hai mới thoát.
      canPop: false,
      onPopInvokedWithResult: _onRootPop,
      child: ListenableBuilder(
        listenable: widget.cartController,
        builder: (context, _) {
          final cart = widget.cartController.cart;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Thực đơn'),
              bottom: const CurrentUrlBar(),
              actions: [
                IconButton(
                  icon: Badge(
                    label: Text('${cart.totalQuantity}'),
                    isLabelVisible: !cart.isEmpty,
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  onPressed: cart.isEmpty ? null : _openCart,
                ),
              ],
            ),
            body: FutureBuilder<List<Food>>(
              future: widget.foodsFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Không tải được thực đơn: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final food in snapshot.data!)
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        food.name,
                                        style: textTheme.titleMedium,
                                      ),
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
                    TextField(
                      controller: _pathController,
                      decoration: InputDecoration(
                        labelText: 'Nhập đường dẫn',
                        hintText: '/food/pho',
                        errorText: _pathError,
                        border: const OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.go,
                      onChanged: (_) {
                        if (_pathError != null) {
                          setState(() => _pathError = null);
                        }
                      },
                      onSubmitted: (_) => _goToPath(),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      // [NAV] go: mở đường dẫn nội bộ ở chế độ xem món.
                      onPressed: _goToPath,
                      child: const Text('Đi'),
                    ),
                    const SizedBox(height: 24),
                    Text('Demo Navigator 1.0', style: textTheme.labelLarge),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      // [NAV] mở màn ngoài go_router bằng Navigator.push
                      onPressed: _openAbout,
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Mở Giới thiệu bằng Navigator.push'),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
