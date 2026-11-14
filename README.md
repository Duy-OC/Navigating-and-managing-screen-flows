# Gọi món mini – Demo điều hướng Flutter (Navigator + Router API)

> Lưu ý: project Flutter (package `food_nav_demo`) nằm ngay ở thư mục gốc của repo này, không phải trong thư mục con `food_nav_demo`.

## 1. Giới thiệu

Ứng dụng gọi món gồm 3 màn hình (Thực đơn, Chi tiết món, Giỏ hàng) và một màn lỗi. Dữ liệu món ăn là dữ liệu mẫu viết cứng trong bộ nhớ, giỏ hàng chỉ nằm trong `State`, tắt app là mất. Mục tiêu của bài là minh họa điều hướng bằng `go_router` (Router API), không phải làm app bán hàng hoàn chỉnh. Các chỗ liên quan đến điều hướng trong code đều có comment bắt đầu bằng `// [NAV]`.

## 2. Cách chạy

```bash
flutter create . --platforms android --project-name food_nav_demo   # lần đầu: sinh thư mục android/ (không ghi đè lib/)
rm -f test/widget_test.dart   # xóa test mẫu do flutter create sinh ra
flutter pub get
flutter run        # Android emulator
flutter analyze
flutter test
```

## 3. Đối chiếu yêu cầu đề bài và code

| Yêu cầu | Trong code |
|---|---|
| Navigator, route, truyền tham số | `push('/food/:id')` + `pathParameters`; `pushNamed('cart', extra:)`; `pop(result)`; `Navigator.pop` trong dialog |
| Named routes | `name: 'menu' / 'food' / 'cart'`, `context.pushNamed('cart')` |
| Router API khi luồng phức tạp | `MaterialApp.router`, `GoRouter`, route con, `go` vs `push`, `errorBuilder`, mở thẳng URL |
| Quay lại, trạng thái điều hướng | `PopScope` ở Chi tiết; Back sau khi mở bằng `go`; `extra` mất khi mở thẳng `/cart` |
| Điều hướng và trải nghiệm người dùng | Dialog xác nhận trước khi bỏ món/đặt hàng, SnackBar phản hồi, nút giỏ tắt khi trống, URL hiển thị dưới AppBar |

Cấu hình route nằm trong `lib/router.dart`, các màn hình trong `lib/screens/`.

Logic nghiệp vụ (cộng dồn giỏ, tổng tiền, giới hạn số lượng) nằm trong `lib/models/cart.dart` (đối tượng `Cart` bất biến, truyền qua `extra`), có unit test ở `test/cart_test.dart` và `test/format_test.dart`. Các màn hình chỉ hiển thị và điều hướng.

## 4. So sánh với Navigator 1.0

```dart
// Navigator 1.0 – named routes kiểu cũ
MaterialApp(
  onGenerateRoute: (settings) {
    if (settings.name == '/cart') {
      return MaterialPageRoute(builder: (_) => CartScreen(cart: settings.arguments as Cart));
    }
    return null;
  },
);
Navigator.pushNamed(context, '/cart', arguments: cart);
```

Navigator 1.0 quản lý stack bằng các lệnh push/pop, đủ dùng cho app nhỏ. Router API (qua go_router) khai báo màn hình theo URL, nên cần khi có deep link, web, hoặc mở thẳng một màn ở giữa luồng. Khi đó stack được dựng lại theo cây route thay vì do code tự đẩy từng màn. Đoạn code trên chỉ để so sánh, không có trong app.

## 5. `push` khác `go` thế nào

- `context.push` xếp màn mới lên trên stack và có thể `await` để nhận kết quả khi màn đó `pop(result)`.
- `context.go` nhảy tới URL như mở một liên kết, stack được dựng lại theo cây route và không nhận kết quả trả về.

Ví dụ: nút "Mở thẳng /food/pho" dùng `go`. Màn Chi tiết mở ra, Back vẫn về Thực đơn (vì route con dựng stack `/` rồi `/food/pho`). Nhưng bấm "Thêm vào giỏ" thì giỏ không tăng, vì không có màn nào đang `await` kết quả. Đây là hành vi đúng, dùng để minh họa khác biệt giữa `go` và `push`.

## 6. Sơ đồ luồng và kịch bản demo

### Sơ đồ luồng

```
Thực đơn (/) ──push('/food/:id')──► Chi tiết (/food/banh-mi)
Thực đơn     ◄──pop(quantity)────── Chi tiết          (bấm "Thêm")
Thực đơn     ◄──pop() / null──────── Chi tiết          (Back; nếu đã đổi số lượng → dialog "Bỏ chọn món?")

Thực đơn ──pushNamed('cart', extra: giỏ)──► Giỏ hàng (/cart)
Thực đơn ◄──pop(true)────────────────────── Giỏ hàng   (Đặt hàng → xóa giỏ + SnackBar)

Nút "Mở thẳng /food/pho" ──go──► stack dựng lại: / → /food/pho   (Back về Thực đơn, không trả kết quả)
Nút "Thử /xyz" ──go──► errorBuilder ──► Màn lỗi ──go('/')──► Thực đơn
```

### Kịch bản demo (khoảng 5 phút, Android emulator)

Chỉ cho cả lớp xem dòng URL dưới AppBar ở mỗi bước.

1. Truyền dữ liệu đi/về: chạm Bánh mì (URL `/food/banh-mi`), tăng lên 2, bấm Thêm, về Thực đơn, SnackBar "Đã thêm 2 Bánh mì", badge 2.
2. Xử lý Back: chạm Bánh mì, đổi thành 3, bấm Back hệ thống, dialog "Bỏ chọn món?", chọn "Ở lại", Back lần nữa, chọn "Bỏ chọn", giỏ vẫn 2 (Chi tiết trả về `null`).
3. Back không hỏi: chạm Trà sữa, không đổi gì, Back, về ngay.
4. Named route + extra: bấm giỏ hàng (URL `/cart`), xem tổng, Đặt hàng, xác nhận, về Thực đơn, giỏ trống, SnackBar.
5. Router API – go: bấm "Mở thẳng /food/pho", Chi tiết Phở mở ra, bấm Back, vẫn về Thực đơn.
6. URL sai: bấm "Thử URL không tồn tại /xyz", màn lỗi, bấm "Về thực đơn".

## 7. Nguồn ảnh

Xem `assets/images/CREDITS.md`.
