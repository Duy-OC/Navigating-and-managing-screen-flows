import 'package:flutter/material.dart';
import 'package:food_nav_demo/router.dart';

void main() {
  // Đọc asset sau khi Flutter đã khởi tạo dịch vụ cho rootBundle.
  WidgetsFlutterBinding.ensureInitialized();
  // Chỉ tạo GoRouter một lần cho cả app.
  final router = createRouter();

  runApp(MaterialApp.router(
    title: 'Gọi món',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
    // [NAV] Router API: app điều hướng theo cấu hình route, không theo stack tự quản
    routerConfig: router,
  ));
}
