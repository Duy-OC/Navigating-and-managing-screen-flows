import 'package:flutter/material.dart';
import 'package:food_nav_demo/widgets/current_url_bar.dart';

/// Màn minh họa Navigator 1.0: được mở bằng Navigator.push(MaterialPageRoute)
/// và trả kết quả bằng Navigator.pop(context, result).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giới thiệu'),
        bottom: const CurrentUrlBar(url: 'Navigator.push → /about'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Màn này dùng Navigator 1.0', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(
            'Thực đơn gọi Navigator.of(context).push(MaterialPageRoute(...)) '
            'để mở màn này. Đây là route không do go_router quản lý, nằm trên '
            'stack của Navigator gốc.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Nút bên dưới gọi Navigator.pop(context, result) để trả một chuỗi '
            'về Thực đơn. Thực đơn nhận kết quả và hiển thị SnackBar, minh họa '
            'truyền dữ liệu khi quay lại màn trước.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Nhấn Back trên AppBar sẽ đóng màn và trả null, tương đương thao '
            'tác hủy.',
            style: textTheme.bodyMedium,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () => Navigator.pop(context, 'Đã đóng màn Giới thiệu'),
            child: const Text('Đã hiểu'),
          ),
        ),
      ),
    );
  }
}
