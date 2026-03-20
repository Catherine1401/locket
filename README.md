# Locket 📸

**Chia sẻ khoảnh khắc thường nhật với những người bạn thực sự quan tâm.**  
Một ứng dụng *no social network* — không kiếm view, không bon chen, chỉ có sự thân mật.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9+-blue.svg?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## ✨ Demo / Screenshots

> *(Screenshots sẽ được cập nhật sau)*

| Camera | Feed | Profile |
|--------|------|---------|
| — | — | — |

---

## 📱 Features

### Authentication
- [x] Đăng nhập / đăng ký bằng Google (Google Sign-In)
- [x] JWT — tự động refresh access token khi hết hạn
- [x] Bảo vệ route — redirect về Login nếu chưa đăng nhập

### Profile
- [x] Xem thông tin cá nhân (tên, avatar, ngày sinh)
- [x] Cập nhật tên hiển thị
- [x] Cập nhật ảnh đại diện

### Friends
- [x] Kết bạn qua deeplink (`locket://add-friend/<shareCode>`)
- [x] Gửi / thu hồi yêu cầu kết bạn
- [x] Xem & phản hồi yêu cầu kết bạn đến (accept / reject)
- [x] Xem danh sách bạn bè
- [x] Hủy kết bạn

### Moments
- [x] Chụp ảnh trực tiếp bằng camera (không cho phép chọn từ gallery)
- [x] Thêm caption (≤ 100 ký tự)
- [x] Xem moment dạng **Feed** (fullsize, vuốt dọc, phân trang cursor)
- [x] Xem moment dạng **Grid** (lưới thumbnail)
- [x] Lọc feed theo từng người bạn
- [x] Điều hướng từ Grid → đúng moment trong Feed

### Messages
- [x] Nhắn tin với bạn bè (text + emoji)
- [x] Reply moment của bạn bè (hiển thị thumbnail kèm tin nhắn)
- [x] Realtime qua Socket.IO
- [ ] Chỉnh sửa tin nhắn (trong vòng 15 phút)
- [ ] Thu hồi / xóa tin nhắn
- [ ] React tin nhắn

### Sắp ra mắt
- [ ] React moment (emoji reactions)
- [ ] Xem danh sách reaction của một moment
- [ ] Push Notifications

---

## 🚀 Getting Started

### Yêu cầu

- [Flutter](https://flutter.dev/docs/get-started/install) 3.x trở lên
- Dart 3.9+
- Android Studio / VS Code + Flutter extension
- iOS: Xcode 15+ (nếu build cho iOS)

### Clone & Cài đặt

```bash
git clone https://github.com/Catherine1401/locket.git
cd locket
flutter pub get
```

### Biến môi trường

Dự án sử dụng `--dart-define` thay vì file `.env`. Tạo file `env/dev.sh` (hoặc tương tự):

```bash
export HOST="https://your-api-host.com"
export WEB_CLIENT_ID="your-google-web-client-id"
export ANDROID_CLIENT_ID="your-google-android-client-id"
```

### Chạy ứng dụng

```bash
flutter run \
  --dart-define=HOST=$HOST \
  --dart-define=WEB_CLIENT_ID=$WEB_CLIENT_ID \
  --dart-define=ANDROID_CLIENT_ID=$ANDROID_CLIENT_ID
```

### Build release

```bash
# Android
flutter build apk --release \
  --dart-define=HOST=$HOST \
  --dart-define=WEB_CLIENT_ID=$WEB_CLIENT_ID \
  --dart-define=ANDROID_CLIENT_ID=$ANDROID_CLIENT_ID

# iOS
flutter build ios --release \
  --dart-define=HOST=$HOST \
  --dart-define=WEB_CLIENT_ID=$WEB_CLIENT_ID \
  --dart-define=ANDROID_CLIENT_ID=$ANDROID_CLIENT_ID
```

---

## 🏗️ Cấu trúc dự án

Dự án theo **Clean Architecture**, tổ chức theo feature:

```
lib/
├── main.dart                  # Entry point
├── core/                      # Hạ tầng dùng chung
│   ├── config/                # Token model
│   ├── injection.dart         # Dependency injection (Dio, Router, Socket...)
│   ├── network/               # Dio interceptor, Socket.IO service
│   ├── theme/                 # Colors, TextStyle, ShadCN theme
│   └── utils/                 # DeeplinkService, AuthEventBus
├── shared/
│   └── presentation/          # Shared widgets & RootScreen
└── features/
    ├── users/                 # Auth + Profile
    ├── moments/               # Camera, Feed, Grid, Preview
    ├── friends/               # Friend list, requests, deeplink
    └── messages/              # Conversations, Chat
```

Mỗi feature có cấu trúc 3 lớp:

```
feature/
├── data/          # Datasource (gọi API) + Repository impl
├── domain/        # Entities + Repository interface + Use cases
├── presentation/  # Screens + Widgets + Riverpod providers
└── injection.dart # Wire-up DI
```

---

## 🛠️ Tech Stack

| Lớp | Thư viện |
|-----|----------|
| **State Management** | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) + [hooks_riverpod](https://pub.dev/packages/hooks_riverpod) + [flutter_hooks](https://pub.dev/packages/flutter_hooks) |
| **Routing** | [go_router](https://pub.dev/packages/go_router) |
| **Networking** | [dio](https://pub.dev/packages/dio) |
| **Realtime** | [socket_io_client](https://pub.dev/packages/socket_io_client) |
| **Auth** | [google_sign_in](https://pub.dev/packages/google_sign_in) |
| **Storage** | [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) |
| **Deep Linking** | [app_links](https://pub.dev/packages/app_links) |
| **Camera** | [camera](https://pub.dev/packages/camera) |
| **Image** | [cached_network_image](https://pub.dev/packages/cached_network_image) · [image](https://pub.dev/packages/image) · [image_picker](https://pub.dev/packages/image_picker) · [gal](https://pub.dev/packages/gal) |
| **UI** | [shadcn_ui](https://pub.dev/packages/shadcn_ui) · [flutter_svg](https://pub.dev/packages/flutter_svg) · [sliver_tools](https://pub.dev/packages/sliver_tools) |
| **Font** | [Inter](https://fonts.google.com/specimen/Inter) (Variable Font) |

---

## 📄 License

Distributed under the MIT License.

---

## 📧 Contact

**Huy** · [@Catherine1401_](https://github.com/Catherine1401)  
Project: [github.com/Catherine1401/locket](https://github.com/Catherine1401/locket)
