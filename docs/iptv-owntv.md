# Hướng Dẫn Cấu Hình IPTV (OwnTV) & Tối Ưu Màn Hình TV

Tài liệu này ghi lại chi tiết giải pháp xem truyền hình IPTV miễn phí bằng ứng dụng **OwnTV**, danh sách kênh Việt Nam chất lượng cao và thiết lập chống tắt màn hình chờ cho Smart TV Sony BRAVIA.

---

## 1. Vì Sao Chọn OwnTV Thay Vì TiviMate?

Trong quá trình đánh giá các ứng dụng IPTV trên Android TV:
* **TiviMate**: Là ứng dụng IPTV rất phổ biến nhưng là phần mềm thương mại trả phí bản quyền (khoảng ~30$ trọn đời hoặc 10$/năm). Khi không mua bản quyền (bản Free), TiviMate bị khóa hầu hết tính năng quan trọng: không có EPG, không lưu kênh yêu thích, không hỗ trợ quản lý nhóm kênh, không xem lại.
* **OwnTV (v5.2.0)**:
  * Mã nguồn mở 100% ([GitHub: ahXN00/OwnTV](https://github.com/ahXN00/OwnTV)).
  * Miễn phí hoàn toàn, không quảng cáo, không yêu cầu tài khoản hay trả phí.
  * Giao diện Material 3 tuyệt đẹp, thiết kế chuẩn cho Google TV và điều khiển bằng remote.
  * Hỗ trợ phát đa luồng song song qua **ExoPlayer** và **libmpv** với độ phân giải Full HD 1080p, âm thanh vòm Stereo/5.1.
  * Tích hợp máy chủ web nội bộ (Web Server) trên cổng `8089` giúp nạp danh sách kênh cực kỳ tiện lợi qua máy tính hoặc điện thoại mà không cần gõ bàn phím ảo bằng remote.

---

## 2. Thông Tin Cấu Hình Playlist & Lịch Phát Sóng (EPG)

* **Tên ứng dụng:** OwnTV v5.2.0
* **Package:** `tv.own.owntv`
* **Nguồn danh sách kênh (M3U Playlist):**
  ```
  https://tanphat-vn-tv.tanphat-laser.workers.dev/
  ```
  * **Số lượng kênh:** 253 kênh.
  * **Phân nhóm đầy đủ:** VTV HD, VTVcab, SCTV, HTV, HTVC, Kênh địa phương, Kênh thể thao quốc tế, Phim truyện, Thiếu nhi,...
* **Nguồn lịch phát sóng (EPG XML):**
  ```
  https://lichphatsong.io.vn/epg.xml
  ```
  * Hiển thị chi tiết tên chương trình đang phát, chương trình kế tiếp và thanh tiến trình thời gian thực.

---

## 3. Cách Cài Đặt & Cấu Hình Nhanh Qua Mạng Cục Bộ

### Bước 1: Cài đặt ứng dụng OwnTV lên TV qua ADB
```bash
# Tải file APK OwnTV v5.2.0 từ GitHub Releases
curl -L -s -o /tmp/OwnTV-v5.2.0.apk https://github.com/ahXN00/OwnTV/releases/download/v5.2.0/OwnTV-v5.2.0.apk

# Đẩy file và cài đặt qua tv.py
cd /Users/khanhkd1/.gemini/antigravity/scratch/cleanyourtv
tools/venv/bin/python tools/tv.py --push /tmp/OwnTV-v5.2.0.apk /data/local/tmp/owntv.apk
tools/venv/bin/python tools/tv.py "pm install -r /data/local/tmp/owntv.apk"
tools/venv/bin/python tools/tv.py "rm -f /data/local/tmp/owntv.apk"
```

### Bước 2: Nạp Playlist & EPG qua Web UI
1. Mở ứng dụng OwnTV trên TV, vào phần Cài đặt / Thêm Profile (New Profile).
2. TV sẽ hiển thị mã PIN xác thực (gồm 6 số) và địa chỉ web nội bộ: `http://<IP-CỦA-TV>:8089`.
3. Trên máy tính hoặc điện thoại cùng mạng Wi-Fi, truy cập vào `http://<IP-CỦA-TV>:8089`, nhập mã PIN hiển thị trên TV.
4. Nhập thông tin:
   * **Profile Name:** `Vietnam TV`
   * **Type:** `M3U Playlist`
   * **M3U URL:** `https://tanphat-vn-tv.tanphat-laser.workers.dev/`
   * **EPG URL:** `https://lichphatsong.io.vn/epg.xml`
5. Nhấn Lưu (Save), OwnTV trên TV sẽ tự động đồng bộ toàn bộ 253 kênh và nạp dữ liệu lịch phát sóng trong vài giây.

---

## 4. Hướng Dẫn Điều Khiển Bằng Remote TV

| Phím bấm trên Remote | Chức năng trong OwnTV |
| :--- | :--- |
| **Chọn ứng dụng** | Nhấn **OK** tại icon **OwnTV** trên màn hình chính CleanYourTV. App sẽ mở ngay và tự động tiếp tục phát kênh bạn xem gần nhất. |
| **Nút Trái (◀ D-Pad)** | Mở ngăn kéo **Danh mục nhóm kênh** (Thể thao, VTV, VTVcab, SCTV, HTV, Sự kiện,...). |
| **Nút OK (Giữa D-Pad)** | Khi đang xem: Tạm dừng / Tiếp tục phát và hiện thanh thông tin chương trình (tên tiết mục, giờ phát sóng). |
| **Nút Lên / Xuống (▲ / ▼)** | Chuyển kênh kế tiếp hoặc kênh trước đó. |
| **Nút Quay lại (Back)** | Thu nhỏ video về khung preview và mở danh sách toàn bộ kênh + EPG. |
| **Giữ nút OK (Long press)** | Mở menu tùy chọn kênh (Thêm vào mục Yêu thích ❤️, chỉnh tỷ lệ khung hình 16:9 / 4:3, đổi luồng phát, chọn track âm thanh). |

---

## 5. Cấu Hình Tắt Màn Hình Chờ (Luôn Giữ Màn Hình Đang Xem)

Theo yêu cầu giữ TV luôn ở màn hình hiện tại mà không tự động chuyển sang chế độ bảo vệ màn hình (Ambient Mode) hay tự tắt sau vài phút không sử dụng:

### Lệnh cấu hình qua ADB:
```bash
# Vô hiệu hóa màn hình chờ mặc định của Google TV
settings put secure screensaver_enabled 0

# Giữ TV luôn thức khi được cấp nguồn
settings put global stay_on_while_plugged_in 7
```

### Cấu hình trên giao diện TV (Sony Eco Dashboard):
1. Vào **Cài đặt (⚙️)** ➔ **Hệ thống (System)** ➔ **Nguồn và năng lượng (Power & Energy)**.
2. Chọn **Trình tiết kiệm pin (Energy Saver)**.
3. Tại mục **Tắt TV sau (Turn off TV after)**: Chọn **Không bao giờ (Never)**.
