import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_nav_demo/router.dart';
import 'package:go_router/go_router.dart';

Future<GoRouter> _pumpApp(WidgetTester tester) async {
  // Màn hình đủ lớn để các nút ở đáy hiển thị mà không cần cuộn.
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final router = createRouter();
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

  testWidgets('4. Back khi không đổi gì thì về thẳng Thực đơn',
      (tester) async {
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

  testWidgets('6. URL không hợp lệ hiện thông báo không tìm thấy',
      (tester) async {
    final router = await _pumpApp(tester);

    router.go('/food/pizza');
    await tester.pumpAndSettle();
    expect(find.text('Không tìm thấy món "pizza"'), findsOneWidget);

    router.go('/xyz');
    await tester.pumpAndSettle();
    expect(find.text('Không tìm thấy trang'), findsWidgets);
  });
}
