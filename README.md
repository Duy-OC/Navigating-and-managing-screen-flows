# Gọi món mini

## 1. Tổng quan

Ứng dụng Flutter minh họa điều hướng và quản lý luồng màn hình khi gọi món. Dữ liệu món được đọc từ CSV; giỏ hàng được giữ trong bộ nhớ trong suốt phiên chạy.

## 2. Tính năng chính

- Xem thực đơn, chi tiết món, chọn số lượng và thêm vào giỏ; tối đa 10 phần cho mỗi món.
- Xem giỏ, xác nhận đặt hàng và nhận phản hồi bằng SnackBar.
- Nhập đường dẫn nội bộ trong **Demo Router API** rồi bấm **Đi** hoặc Enter. `/food/pho` và `/food/banh-mi` mở chế độ chỉ xem; `/food/pizza` báo không tìm thấy món; `/xyz` mở trang lỗi. Ô trống, đường dẫn thiếu `/` đầu và URL ngoài app được báo lỗi tại ô nhập.
- Xác nhận trước khi rời màn chi tiết nếu đã đổi số lượng; mở màn Giới thiệu bằng Navigator 1.0.

## 3. Công nghệ sử dụng

- Flutter và Dart; `go_router` cho route có tên, tham số URL và điều hướng `go`/`push`.
- `Navigator` và `PopScope` cho luồng Back, hộp thoại và kết quả trả về.
- Gói `csv` để đọc `assets/data/foods.csv`; `CartController` giữ trạng thái giỏ trong bộ nhớ.

## 4. Hướng dẫn cài đặt

Cần Flutter SDK và môi trường Android đã thiết lập. Tại thư mục gốc dự án:

```bash
flutter pub get
flutter run
```

Kiểm tra mã nguồn và test:

```bash
flutter analyze
flutter test
```

APK đã xuất nằm tại [`release/goi-mon-mini-v1.0.0.apk`](release/goi-mon-mini-v1.0.0.apk). Có thể tự build lại bằng `flutter build apk --release`. Bản APK hiện dùng khóa debug theo cấu hình `android/app/build.gradle.kts`.

## 5. Cách sử dụng

1. Chạm món trong **Thực đơn**, tăng hoặc giảm số lượng rồi bấm **Thêm vào giỏ**. Màn chi tiết trả số lượng về Thực đơn qua `pop(quantity)`.
2. Mở **Giỏ hàng** bằng biểu tượng trên AppBar, xem món và xác nhận đặt hàng. Back giữ nguyên giỏ.
3. Trong **Demo Router API**, nhập `/food/pho` và bấm **Đi** để xem món mà không chọn số lượng. Dùng Back hoặc **Về thực đơn** để quay lại. Thử `/food/pizza`, `/xyz` hoặc ô trống để xem cách app xử lý lỗi.
4. Bấm **Mở Giới thiệu bằng Navigator.push** để xem ví dụ Navigator 1.0.

Ô nhập chỉ mô phỏng điều hướng URL nội bộ; deep link từ ngoài app chưa được cấu hình. Muốn thêm món, thêm dòng vào `assets/data/foods.csv` với các cột `id,name,price,description,image`, đặt ảnh tương ứng trong `assets/images/`, rồi khởi động lại app để đóng gói asset mới.

## 6. Cấu trúc thư mục

```text
android/             Cấu hình ứng dụng Android
assets/data/         Dữ liệu món dạng CSV
assets/images/       Ảnh món và thông tin nguồn ảnh
lib/data/            Đọc dữ liệu món
lib/models/          Food, Cart và tham số route
lib/screens/         Thực đơn, chi tiết, giỏ, giới thiệu, trang lỗi
lib/state/           CartController
lib/widgets/         Widget dùng chung
lib/router.dart      Cấu hình go_router
test/                Unit test và test điều hướng
release/             APK đã xuất
```

## 7. Giấy phép

Dự án chưa có tệp LICENSE, vì vậy chưa công bố giấy phép sử dụng mã nguồn. Ảnh có giấy phép riêng; xem [`assets/images/CREDITS.md`](assets/images/CREDITS.md) để biết nguồn, tác giả và giấy phép từng ảnh.
