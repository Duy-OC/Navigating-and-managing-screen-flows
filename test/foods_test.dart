import 'package:flutter_test/flutter_test.dart';
import 'package:food_nav_demo/data/foods.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('nạp đúng ba món từ asset CSV', () async {
    final foods = await loadFoods();
    expect(foods.map((food) => food.id), ['banh-mi', 'pho', 'tra-sua']);
    expect(foods.map((food) => food.price), [25000, 45000, 30000]);
    expect(findFoodById(foods, 'pho')!.image, 'assets/images/pho.jpg');
  });

  test('CSV hiểu dấu phẩy và dấu nháy kép trong mô tả', () {
    final foods = parseFoodsCsv(
      'id,name,price,description,image\n'
      'pho,Phở bò,45000,"Nước dùng, thịt bò ""tái""",assets/images/pho.jpg',
    );
    expect(foods.single.description, 'Nước dùng, thịt bò "tái"');
  });

  test('CSV trống và dòng sai định dạng báo lỗi', () {
    expect(() => parseFoodsCsv(''), throwsFormatException);
    expect(() => parseFoodsCsv('id,name,price,description,image\n'),
        throwsFormatException);
    expect(
      () => parseFoodsCsv(
          'id,name,price,description,image\npho,Phở bò,sai,mô tả,assets/images/pho.jpg'),
      throwsFormatException,
    );
  });
}
