# Gọi món mini – Chủ đề 9: Điều hướng và quản lý luồng màn hình

Project Flutter `food_nav_demo` nằm ngay tại thư mục gốc. App có bốn màn hình chính: Thực đơn, Chi tiết món, Giỏ hàng, Giới thiệu; thêm màn báo lỗi đường dẫn. Dữ liệu món nằm trong `assets/data/foods.csv`, ảnh ở `assets/images/`. Giỏ hàng chỉ giữ trong bộ nhớ khi app đang chạy, nhưng được quản lý ở cấp ứng dụng nên không mất khi điều hướng.

## Chạy và kiểm tra

```bash
flutter pub get
flutter run
flutter analyze
flutter test
```

Thư mục `android/` đã có sẵn. Có thể chạy trên Android emulator hoặc thiết bị thật đã bật USB debugging.

## Đối chiếu yêu cầu Chủ đề 9

| Nội dung | Minh họa trong app |
|---|---|
| Navigator, route, truyền tham số | Thực đơn dùng `pushNamed<int>('food', pathParameters: {'id': ...}, extra: FoodRouteArgs(...))`; Chi tiết đọc `id` từ `pathParameters`, trả số lượng bằng `context.pop(quantity)`; màn Giới thiệu dùng `Navigator.push(MaterialPageRoute)` và `Navigator.pop(result)`; dialog dùng `Navigator.pop` |
| Named routes | `GoRoute(name: 'menu')`, `'food'` và `'cart'`; gọi bằng `context.pushNamed` với `pathParameters`/`extra` hoặc `context.goNamed('menu')`; đây là API của **go_router**, không phải `Navigator.pushNamed()` của Navigator 1.0 |
| Router API | `MaterialApp.router`, `GoRouter`, route con, `errorBuilder`, `go()` và `push()` trong `lib/router.dart`; `extra` có kiểu `FoodRouteArgs`/`Cart` |
| Back và trạng thái | `PopScope` hỏi trước khi bỏ số lượng đã đổi; Back ở Thực đơn nhấn hai lần mới thoát; `CartController` giữ giỏ ở cấp app; `pop(qty)`/`pop(true)`; Back từ Giỏ hàng giữ nguyên giỏ |
| Trải nghiệm người dùng | SnackBar phản hồi, badge số món, trạng thái giỏ trống, thông báo CSV lỗi, màn lỗi URL; mỗi món tối đa 10 phần |

`push()` thêm màn lên stack và có thể chờ kết quả từ `pop(result)`. `pushNamed` vừa dùng named route vừa truyền `pathParameters` và object `FoodRouteArgs` qua `extra`. `go()` chuyển tới vị trí route mới; không có lời gọi `await` để nhận kết quả. `CartController` được tạo một lần trong `createRouter` và truyền cho Thực đơn/Giỏ hàng, nên giỏ không mất khi route bị dựng lại (ví dụ mở `/xyz` rồi quay về). Mở trực tiếp `/cart` không có `extra` sẽ dùng giỏ hiện tại trong bộ nhớ; nếu giỏ trống thì hiện trạng thái trống. Mỗi món tối đa 10 phần; Chi tiết hiển thị số đã có trong giỏ và khóa nút thêm khi đủ.

Trong phần **Demo Router API**, nhập đường dẫn nội bộ (gợi ý `/food/pho`) rồi bấm **Đi** hoặc Enter. Ô nhập bỏ khoảng trắng hai đầu, báo lỗi dưới ô khi trống hoặc thiếu dấu `/` đầu và chặn URL ngoài app. Đường dẫn hợp lệ được mở bằng `go(path)`: `/food/pho` và `/food/banh-mi` mở Chi tiết ở chế độ chỉ xem, `/food/pizza` báo không tìm thấy món, `/xyz` mở màn **Không tìm thấy trang**. Nút **Về thực đơn** và Back từ chi tiết món hợp lệ đưa về Thực đơn. Chọn món từ danh sách vẫn dùng `pushNamed<int>()` để chọn số lượng và trả kết quả khi thêm vào giỏ. Nút **Mở Giới thiệu bằng Navigator.push** minh họa Navigator 1.0: mở một `MaterialPageRoute` ngoài go_router, trả chuỗi bằng `Navigator.pop` và hiện SnackBar ở Thực đơn.

Ô nhập `go()` trong app chỉ mô phỏng điều hướng tới URL nội bộ. **Deep link từ bên ngoài app** còn cần cấu hình Android App Links hoặc intent filter, và chưa được cấu hình trong dự án này.

## Dữ liệu CSV và ảnh

`assets/data/foods.csv` mã hóa UTF-8, gồm các cột `id,name,price,description,image`. Để thêm món, thêm một dòng với ID duy nhất dạng `chu-thuong-gach-noi`, giá nguyên dương và đường dẫn ảnh nội bộ. Ví dụ:

```csv
bun-cha,Bún chả,40000,"Bún, chả nướng và nước mắm.",assets/images/bun-cha.jpg
```

Đặt ảnh `bun-cha.jpg` vào `assets/images/`, ghi nguồn và giấy phép trong `assets/images/CREDITS.md`, rồi chạy lại app. Đặt trường chứa dấu phẩy hoặc dấu nháy kép trong dấu nháy kép; một dấu nháy kép bên trong được viết thành `""`. Nếu ảnh thiếu, app hiện tên món thay thế. Nếu CSV trống, sai cột hoặc sai dữ liệu, app hiện thông báo lỗi thực đơn.

Sau khi thêm hoặc đổi asset CSV/ảnh, dừng hẳn phiên `flutter run` và chạy lại để Flutter đóng gói asset mới; hot reload không cập nhật danh sách asset trong bản đang chạy.

## Kịch bản demo khoảng 15 phút

1. **3 phút:** giới thiệu route tree trong `lib/router.dart`, `Navigator`, `go_router`, `push`, `go`, `pop`, named route, `FoodRouteArgs` và `CartController`.
2. **4 phút:** chọn Bánh mì, tăng số lượng lên 2, bấm **Thêm vào giỏ**; xem `id` trong URL, `pop(2)`, SnackBar và badge. Mở lại món để thấy dòng **Trong giỏ**, thêm đến 10 phần và quan sát nút bị khóa.
3. **3 phút:** đổi số lượng rồi dùng Back AppBar hoặc Back hệ thống Android; chọn **Ở lại** để giữ số lượng, thử lại và chọn **Bỏ chọn**. Ở Thực đơn, nhấn Back một lần để thấy nhắc nhở, nhấn lần nữa để thoát.
4. **2 phút:** mở Giỏ hàng bằng named route, Back để thấy giỏ còn; vào lại, xác nhận đặt hàng và xem badge biến mất. Mở trực tiếp `/cart` để thấy giỏ hiện tại được dùng làm fallback.
5. **2 phút:** ở **Demo Router API**, nhập `/food/pho` rồi bấm **Đi** để xem Phở ở chế độ chỉ xem; dùng Back về Thực đơn. Nhập `/food/banh-mi` và nhấn Enter; thử `/food/pizza` để xem món không tồn tại, `/xyz` để xem màn **Không tìm thấy trang** rồi bấm **Về thực đơn**. Thử ô trống và `food/pho` để thấy lỗi dưới ô; kiểm tra giỏ vẫn còn.
6. **1 phút:** mở màn **Giới thiệu** bằng Navigator 1.0, quay lại và xem SnackBar kết quả; mở CSV, giải thích thêm món mới.

## Đóng gói bài nộp

Nộp mã nguồn, `pubspec.yaml`, `pubspec.lock`, `assets/`, `android/`, `test/` và README. `.gitignore` đã loại `.dart_tool/` và `build/`; không đưa hai thư mục sinh tự động này vào file nén hoặc Git. Có thể tạo file nén từ các thư mục/file cần nộp sau khi kiểm tra bằng `git status --short`.

Nguồn ảnh: `assets/images/CREDITS.md`.
