import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:food_nav_demo/models/food.dart';

const foodsCsvAsset = 'assets/data/foods.csv';

Future<List<Food>> loadFoods() async {
  try {
    return parseFoodsCsv(await rootBundle.loadString(foodsCsvAsset));
  } on FormatException {
    rethrow;
  } catch (error) {
    throw FormatException('Không đọc được $foodsCsvAsset: $error');
  }
}

List<Food> parseFoodsCsv(String source) {
  final content = source.replaceFirst('\uFEFF', '').replaceAll('\r\n', '\n');
  if (content.trim().isEmpty) {
    throw const FormatException('CSV thực đơn trống.');
  }

  final List<List<dynamic>> rows;
  try {
    rows = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
      allowInvalid: false,
    ).convert(content);
  } catch (error) {
    throw FormatException('CSV thực đơn sai cú pháp: $error');
  }
  const header = ['id', 'name', 'price', 'description', 'image'];
  if (rows.isEmpty ||
      rows.first.length != header.length ||
      !List.generate(header.length, (i) => rows.first[i].toString().trim())
          .asMap()
          .entries
          .every((entry) => entry.value == header[entry.key])) {
    throw const FormatException(
        'CSV cần các cột id,name,price,description,image.');
  }
  if (rows.length == 1) {
    throw const FormatException('CSV thực đơn không có món ăn.');
  }

  final ids = <String>{};
  final foods = <Food>[];
  for (var i = 1; i < rows.length; i++) {
    final row = rows[i];
    if (row.length != header.length) {
      throw FormatException('Dòng ${i + 1}: cần đúng 5 cột.');
    }
    final fields = row.map((value) => value.toString().trim()).toList();
    final [id, name, priceText, description, image] = fields;
    final price = int.tryParse(priceText);
    if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(id) ||
        !ids.add(id) ||
        name.isEmpty ||
        price == null ||
        price <= 0 ||
        description.isEmpty ||
        !image.startsWith('assets/images/') ||
        image == 'assets/images/') {
      throw FormatException('Dòng ${i + 1}: dữ liệu món không hợp lệ.');
    }
    foods.add(Food(
      id: id,
      name: name,
      price: price,
      description: description,
      image: image,
    ));
  }
  return List.unmodifiable(foods);
}

Food? findFoodById(List<Food> foods, String id) {
  for (final food in foods) {
    if (food.id == id) return food;
  }
  return null;
}
