class Food {
  final String id; // dùng làm tham số URL: /food/banh-mi
  final String name;
  final int price; // đơn vị đồng
  final String description;
  final String image; // đường dẫn ảnh nội bộ, ví dụ assets/images/banh-mi.jpg

  const Food({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
  });
}
