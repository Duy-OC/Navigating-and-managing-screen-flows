import 'package:go_router/go_router.dart';
import 'package:food_nav_demo/data/foods.dart';
import 'package:food_nav_demo/models/cart.dart';
import 'package:food_nav_demo/models/food.dart';
import 'package:food_nav_demo/models/food_route_args.dart';
import 'package:food_nav_demo/screens/cart_screen.dart';
import 'package:food_nav_demo/screens/detail_screen.dart';
import 'package:food_nav_demo/screens/menu_screen.dart';
import 'package:food_nav_demo/screens/not_found_screen.dart';
import 'package:food_nav_demo/state/cart_controller.dart';

GoRouter createRouter({
  Future<List<Food>>? foodsFuture,
  CartController? cartController,
}) {
  final sharedFoods = foodsFuture ?? loadFoods();
  final sharedCart = cartController ?? CartController();
  return GoRouter(
    initialLocation: '/',
    // [NAV] URL không khớp route nào → màn lỗi (tương đương onUnknownRoute của Navigator)
    errorBuilder: (context, state) =>
        NotFoundScreen(location: state.uri.toString()),
    routes: [
      GoRoute(
        path: '/',
        name: 'menu',
        builder: (context, state) => MenuScreen(
          foodsFuture: sharedFoods,
          cartController: sharedCart,
        ),
        // [NAV] route con: mỗi URL vẫn là một màn hình riêng (toàn màn hình).
        // Khai báo là con của '/' để khi mở thẳng URL, Thực đơn nằm bên dưới → Back có chỗ quay về.
        routes: [
          GoRoute(
            path: 'food/:id',
            name: 'food',
            // [NAV] đọc tham số từ URL + args có kiểu từ extra
            builder: (context, state) {
              final extra = state.extra;
              final args = extra is FoodRouteArgs ? extra : null;
              return DetailScreen(
                id: state.pathParameters['id']!,
                foodsFuture: sharedFoods,
                viewOnly: !(args?.selectable ?? false),
                currentQuantity: args?.currentQuantity ?? 0,
              );
            },
          ),
          GoRoute(
            path: 'cart',
            name: 'cart',
            // [NAV] nhận dữ liệu truyền qua extra; mở thẳng bằng URL thì
            // CartScreen dùng giỏ ở cấp app làm fallback.
            builder: (context, state) {
              final extra = state.extra;
              return CartScreen(
                cart: extra is Cart ? extra : null,
                cartController: sharedCart,
              );
            },
          ),
        ],
      ),
    ],
  );
}
