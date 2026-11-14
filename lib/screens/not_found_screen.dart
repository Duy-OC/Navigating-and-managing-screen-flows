import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:food_nav_demo/widgets/current_url_bar.dart';

class NotFoundScreen extends StatelessWidget {
  final String location;

  const NotFoundScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Không tìm thấy trang'),
        bottom: CurrentUrlBar(url: location),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Không có trang nào ở địa chỉ $location',
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                // [NAV] go thay toàn bộ stack về '/'
                onPressed: () => context.go('/'),
                child: const Text('Về thực đơn'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
