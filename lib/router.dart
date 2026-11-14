import 'package:go_router/go_router.dart';
import 'package:food_nav_demo/models/cart_item.dart';
import 'package:food_nav_demo/screens/cart_screen.dart';
import 'package:food_nav_demo/screens/detail_screen.dart';
import 'package:food_nav_demo/screens/menu_screen.dart';
import 'package:food_nav_demo/screens/not_found_screen.dart';

GoRouter createRouter() => GoRouter(
      initialLocation: '/',
      // [NAV] URL không khớp route nào → màn lỗi (tương đương onUnknownRoute của Navigator)
      errorBuilder: (context, state) =>
          NotFoundScreen(location: state.uri.toString()),
      routes: [
        GoRoute(
          path: '/',
          name: 'menu',
          builder: (context, state) => const MenuScreen(),
          // [NAV] route con: mỗi URL vẫn là một màn hình riêng (toàn màn hình).
          // Khai báo là con của '/' để khi mở thẳng URL, Thực đơn nằm bên dưới → Back có chỗ quay về.
          routes: [
            GoRoute(
              path: 'food/:id',
              name: 'food',
              // [NAV] đọc tham số từ URL
              builder: (context, state) =>
                  DetailScreen(id: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'cart',
              name: 'cart',
              // [NAV] nhận dữ liệu truyền qua extra (có thể null nếu mở thẳng bằng URL)
              builder: (context, state) =>
                  CartScreen(items: state.extra as List<CartItem>?),
            ),
          ],
        ),
      ],
    );
