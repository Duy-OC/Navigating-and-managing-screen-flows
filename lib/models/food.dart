class Food {
  final String id; // dùng làm tham số URL: /food/banh-mi
  final String name;
  final int price; // đơn vị đồng
  final String description;
  final String image; // 'assets/images/banh-mi.jpg' hoặc URL https

  const Food({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
  });
}
