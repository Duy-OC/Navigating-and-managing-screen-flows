/// Tham số có kiểu truyền qua `extra` khi mở màn Chi tiết món.
class FoodRouteArgs {
  const FoodRouteArgs({
    required this.selectable,
    this.currentQuantity = 0,
  });

  /// true khi màn được mở từ Thực đơn để chọn số lượng.
  final bool selectable;

  /// Số phần món này đã có trong giỏ, dùng để giới hạn tổng.
  final int currentQuantity;
}
