import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_nav_demo/router.dart';
import 'package:go_router/go_router.dart';
import 'package:food_nav_demo/data/foods.dart';
import 'package:food_nav_demo/models/cart.dart';
import 'package:food_nav_demo/models/cart_item.dart';
import 'package:food_nav_demo/models/food.dart';
import 'package:food_nav_demo/state/cart_controller.dart';

Future<GoRouter> _pumpApp(
  WidgetTester tester, {
  String? csvError,
  CartController? cartController,
}) async {
  // Màn hình đủ lớn để các nút ở đáy hiển thị mà không cần cuộn.
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final loadedFoods = await tester.runAsync(loadFoods);
  final Future<List<Food>> foodsFuture = csvError == null
      ? Future.value(loadedFoods!)
      : Future.delayed(
          const Duration(milliseconds: 1),
          () => throw FormatException(csvError),
        );
  final router = createRouter(
    foodsFuture: foodsFuture,
    cartController: cartController,
  );
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

IconButton _cartButton(WidgetTester tester) => tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.shopping_cart_outlined),
        matching: find.byType(IconButton),
      ),
    );

Future<void> _enterPath(WidgetTester tester, String path) async {
  final input = find.byType(TextField);
  await tester.ensureVisible(input);
  await tester.enterText(input, path);
  await tester.pumpAndSettle();
}

Future<void> _goToPath(WidgetTester tester, String path) async {
  await _enterPath(tester, path);
  await tester.tap(find.widgetWithText(OutlinedButton, 'Đi'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('1. Mở app thấy Thực đơn và 3 món', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Thực đơn'), findsWidgets);
    expect(find.text('Bánh mì'), findsWidgets);
    expect(find.text('Phở bò'), findsWidgets);
    expect(find.text('Trà sữa'), findsWidgets);
  });

  testWidgets('2. Thêm 2 Bánh mì vào giỏ, có SnackBar và badge 2',
      (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Bánh mì').first);
    await tester.pumpAndSettle();
    expect(find.text('Thêm vào giỏ – 25.000đ'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Thêm vào giỏ – 50.000đ'), findsOneWidget);

    await tester.tap(find.text('Thêm vào giỏ – 50.000đ'));
    await tester.pumpAndSettle();

    expect(find.text('Đã thêm 2 Bánh mì'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(Badge), matching: find.text('2')),
      findsOneWidget,
    );
  });

  testWidgets('3. Back sau khi đổi số lượng hỏi lại, chọn Bỏ chọn',
      (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Phở bò').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Bỏ chọn món?'), findsOneWidget);

    await tester.tap(find.text('Bỏ chọn'));
    await tester.pumpAndSettle();

    expect(find.text('Bỏ chọn món?'), findsNothing);
    expect(find.text('Thực đơn'), findsWidgets);
    expect(_cartButton(tester).onPressed, isNull);
  });

  testWidgets('4. Back khi không đổi gì thì về thẳng Thực đơn', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Phở bò').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Bỏ chọn món?'), findsNothing);
    expect(find.text('Thực đơn'), findsWidgets);
    expect(find.text('Trà sữa'), findsWidgets);
  });

  testWidgets('5. Đặt hàng từ giỏ, thành công và badge biến mất',
      (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Bánh mì').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thêm vào giỏ – 25.000đ'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(Badge), matching: find.text('1')),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
    await tester.pumpAndSettle();
    expect(find.text('25.000đ'), findsWidgets);

    await tester.tap(find.widgetWithText(FilledButton, 'Đặt hàng'));
    await tester.pumpAndSettle();
    expect(find.text('Xác nhận đặt hàng?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Đặt hàng'));
    await tester.pumpAndSettle();

    expect(find.text('Đặt hàng thành công'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(Badge), matching: find.text('1')),
      findsNothing,
    );
  });

  testWidgets('6. ô nhập mở món không tồn tại và route không tồn tại',
      (tester) async {
    await _pumpApp(tester);

    await _goToPath(tester, '/food/pizza');
    expect(find.text('Không tìm thấy món "pizza"'), findsOneWidget);
    await tester.tap(find.text('Về thực đơn'));
    await tester.pumpAndSettle();

    await _goToPath(tester, '/xyz');
    expect(find.text('Không tìm thấy trang'), findsWidgets);
    expect(find.text('Không có trang nào ở địa chỉ /xyz'), findsOneWidget);
    await tester.tap(find.text('Về thực đơn'));
    await tester.pumpAndSettle();
    expect(find.text('Thực đơn'), findsWidgets);
  });

  testWidgets('7. go mở Phở ở chế độ chỉ xem', (tester) async {
    await _pumpApp(tester);
    await _goToPath(tester, '  /food/pho  ');

    expect(find.text('Phở bò'), findsWidgets);
    expect(find.byIcon(Icons.add), findsNothing);
    expect(find.textContaining('Thêm vào giỏ'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Về thực đơn'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Thực đơn'), findsWidgets);
    expect(_cartButton(tester).onPressed, isNull);
  });

  testWidgets('7b. Enter mở Bánh mì ở chế độ chỉ xem', (tester) async {
    await _pumpApp(tester);
    await _enterPath(tester, '/food/banh-mi');
    await tester.testTextInput.receiveAction(TextInputAction.go);
    await tester.pumpAndSettle();

    expect(find.text('Bánh mì'), findsWidgets);
    expect(find.byIcon(Icons.add), findsNothing);
    expect(find.textContaining('Thêm vào giỏ'), findsNothing);
    await tester.tap(find.text('Về thực đơn'));
    await tester.pumpAndSettle();
    expect(find.text('Thực đơn'), findsWidgets);
  });

  testWidgets('7c. ô trống và đường dẫn ngoài app báo lỗi dưới ô',
      (tester) async {
    await _pumpApp(tester);
    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Đi'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Đi'));
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập đường dẫn'), findsOneWidget);
    expect(find.text('Thực đơn'), findsWidgets);

    await _goToPath(tester, '   ');
    expect(find.text('Vui lòng nhập đường dẫn'), findsOneWidget);
    expect(find.text('Thực đơn'), findsWidgets);

    await _goToPath(tester, 'food/pho');
    expect(find.text('Đường dẫn phải bắt đầu bằng `/`'), findsOneWidget);
    expect(find.text('Thực đơn'), findsWidgets);

    await _goToPath(tester, '//example.com/food/pho');
    expect(find.text('Chỉ nhập đường dẫn nội bộ của app'), findsOneWidget);
    expect(find.text('Thực đơn'), findsWidgets);
  });

  testWidgets('8. Ở lại giữ số lượng sau Back', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Bánh mì').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ở lại'));
    await tester.pumpAndSettle();

    expect(find.text('Thêm vào giỏ – 50.000đ'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bỏ chọn'));
    await tester.pumpAndSettle();
    expect(_cartButton(tester).onPressed, isNull);
  });

  testWidgets('9. mở /cart trực tiếp không có extra', (tester) async {
    final router = await _pumpApp(tester);
    router.go('/cart');
    await tester.pumpAndSettle();
    expect(find.text('Giỏ hàng trống'), findsOneWidget);
    await tester.tap(find.text('Về thực đơn'));
    await tester.pumpAndSettle();
    expect(find.text('Thực đơn'), findsWidgets);
  });

  testWidgets('10. lỗi tải CSV hiển thị thông báo', (tester) async {
    await _pumpApp(tester, csvError: 'CSV trống');
    expect(find.textContaining('Không tải được thực đơn'), findsOneWidget);
  });

  testWidgets('11. Back hệ thống hỏi khi đã đổi số lượng', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Phở bò').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Bỏ chọn món?'), findsOneWidget);
    await tester.tap(find.text('Ở lại'));
    await tester.pumpAndSettle();
    expect(find.text('Thêm vào giỏ – 90.000đ'), findsOneWidget);
  });

  testWidgets('12. Back từ giỏ giữ nguyên món', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Bánh mì').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thêm vào giỏ – 25.000đ'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(Badge), matching: find.text('1')),
      findsOneWidget,
    );
    expect(_cartButton(tester).onPressed, isNotNull);
  });

  testWidgets('13. xem Phở bằng go không làm mất giỏ', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Bánh mì').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thêm vào giỏ – 25.000đ'));
    await tester.pumpAndSettle();

    await _goToPath(tester, '/food/pho');
    expect(find.textContaining('Thêm vào giỏ'), findsNothing);
    await tester.tap(find.text('Về thực đơn'));
    await tester.pumpAndSettle();
    expect(_cartButton(tester).onPressed, isNotNull);
  });

  testWidgets('14. mở /cart trực tiếp vẫn thấy giỏ hiện tại', (tester) async {
    final router = await _pumpApp(tester);
    await tester.tap(find.text('Bánh mì').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thêm vào giỏ – 25.000đ'));
    await tester.pumpAndSettle();

    router.go('/cart');
    await tester.pumpAndSettle();
    expect(find.text('Giỏ hàng'), findsWidgets);
    expect(find.text('Bánh mì'), findsWidgets);
    expect(find.text('25.000đ'), findsWidgets);
  });

  testWidgets('15. giỏ không mất khi mở URL lỗi rồi quay lại', (tester) async {
    final router = await _pumpApp(tester);
    await tester.tap(find.text('Bánh mì').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thêm vào giỏ – 25.000đ'));
    await tester.pumpAndSettle();

    router.go('/xyz');
    await tester.pumpAndSettle();
    expect(find.text('Không tìm thấy trang'), findsWidgets);

    await tester.tap(find.text('Về thực đơn'));
    await tester.pumpAndSettle();
    expect(find.text('Thực đơn'), findsWidgets);
    expect(_cartButton(tester).onPressed, isNotNull);
    expect(
      find.descendant(of: find.byType(Badge), matching: find.text('1')),
      findsOneWidget,
    );
  });

  testWidgets('16. Navigator.push mở Giới thiệu và trả kết quả',
      (tester) async {
    await _pumpApp(tester);

    final aboutButton = find.text('Mở Giới thiệu bằng Navigator.push');
    await tester.ensureVisible(aboutButton);
    await tester.pumpAndSettle();
    await tester.tap(aboutButton);
    await tester.pumpAndSettle();

    expect(find.text('Giới thiệu'), findsWidgets);
    expect(find.text('Màn này dùng Navigator 1.0'), findsOneWidget);

    await tester.tap(find.text('Đã hiểu'));
    await tester.pumpAndSettle();
    expect(find.text('Đã đóng màn Giới thiệu'), findsOneWidget);
  });

  testWidgets('17. món đã đủ 10 phần thì không cho thêm', (tester) async {
    final loadedFoods = await tester.runAsync(loadFoods);
    final banhMi = findFoodById(loadedFoods!, 'banh-mi')!;
    final controller = CartController(Cart([CartItem(banhMi, 10)]));
    await _pumpApp(tester, cartController: controller);

    await tester.tap(find.text('Bánh mì').first);
    await tester.pumpAndSettle();

    expect(find.text('Trong giỏ: 10/10'), findsOneWidget);
    expect(find.text('Đã đạt tối đa 10 phần'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets('18. Back ở Thực đơn nhắc nhấn lần nữa để thoát', (tester) async {
    await _pumpApp(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Nhấn Back lần nữa để thoát'), findsOneWidget);
  });

  testWidgets('19. ô nhập /xyz dùng go, về Thực đơn vẫn giữ giỏ',
      (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Bánh mì').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thêm vào giỏ – 25.000đ'));
    await tester.pumpAndSettle();

    await _goToPath(tester, '/xyz');

    expect(find.text('Không tìm thấy trang'), findsWidgets);
    await tester.tap(find.text('Về thực đơn'));
    await tester.pumpAndSettle();
    expect(find.text('Thực đơn'), findsWidgets);
    expect(_cartButton(tester).onPressed, isNotNull);
  });
}
