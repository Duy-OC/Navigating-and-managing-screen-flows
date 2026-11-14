import 'package:flutter/material.dart';
import 'package:food_nav_demo/models/food.dart';

class FoodImage extends StatelessWidget {
  final Food food;
  final double? height;
  final double? width;

  const FoodImage({super.key, required this.food, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    // Khung thay thế khi ảnh lỗi: hiện tên món bằng chữ, không icon.
    Widget fallback(BuildContext context, Object error, StackTrace? stack) =>
        Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Text(food.name, textAlign: TextAlign.center),
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: food.image.startsWith('http')
          ? Image.network(food.image,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: fallback)
          : Image.asset(food.image,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: fallback),
    );
  }
}
