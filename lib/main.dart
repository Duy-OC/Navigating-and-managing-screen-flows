import 'package:flutter/material.dart';
import 'package:food_nav_demo/router.dart';

// Chỉ tạo GoRouter một lần cho cả app.
final _router = createRouter();

void main() => runApp(MaterialApp.router(
      title: 'Gọi món',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
      // [NAV] Router API: app điều hướng theo cấu hình route, không theo stack tự quản
      routerConfig: _router,
    ));
