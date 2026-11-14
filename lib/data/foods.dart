import 'package:food_nav_demo/models/food.dart';

const foods = <Food>[
  Food(
    id: 'banh-mi',
    name: 'Bánh mì',
    price: 25000,
    description: 'Bánh mì giòn, pate, thịt nguội và rau thơm.',
    image: 'assets/images/banh-mi.jpg',
  ),
  Food(
    id: 'pho',
    name: 'Phở bò',
    price: 45000,
    description: 'Nước dùng ninh xương, bánh phở mềm, thịt bò tái.',
    image: 'assets/images/pho.jpg',
  ),
  Food(
    id: 'tra-sua',
    name: 'Trà sữa',
    price: 30000,
    description: 'Trà sữa trân châu đường đen.',
    image: 'assets/images/tra-sua.jpg',
  ),
];

Food? findFoodById(String id) => foods.where((f) => f.id == id).firstOrNull;
