# Bản Snapshot Hệ Thống: Sony KD-65X80L (Apple TV Dock V1)

Bản snapshot này lưu lại toàn bộ trạng thái hoàn chỉnh, ổn định và ưng ý nhất của tivi **Sony KD-65X80L (Android 12 Google TV)** tại thời điểm hiện tại.

---

## 1. Thông Tin Chi Tiết Cấu Hình Trong Snapshot

| Thành phần | Trạng thái trong Snapshot |
| :--- | :--- |
| **Giao diện chính (Launcher)** | **CleanYourTV** phong cách Apple TV 4K, bo góc kính mờ, ambient glow, nền đen tuyền |
| **4 Ứng dụng thanh Dock** | **1. FPT Play** (`net.fptplay.ottbox`)<br>**2. SmartTube** (`org.smarttube.stable`)<br>**3. Phim4K** (`com.oxootv.spagreen`)<br>**4. Apple TV** (`com.apple.atve.sony.appletv`) |
| **Ứng dụng YouTube mới** | **SmartTube v32.68** không quảng cáo, giao diện Leanback TV, đã bật tự cập nhật trong app (`REQUEST_INSTALL_PACKAGES`) |
| **Netflix** | **Đã vô hiệu hóa hoàn toàn** (`com.netflix.ninja`, `com.netflix.partner.ncm`) |
| **Bloatware & Telemetry** | **35 gói rác & theo dõi đã tắt** (Samba TV, Sony telemetry, Eco Dashboard, Timers, Sony Album/Music, Living Decor, Vewd...) |
| **Trợ lý Google (Mic remote)** | **Hoạt động hoàn hảo** (LauncherX chạy ngầm hỗ trợ session, HomeKeyService chuyển hướng phím Home mượt mà) |
| **DNS chặn quảng cáo** | **AdGuard Private DNS** (`dns.adguard-dns.com` ở chế độ opportunistic) |
| **Chặn quảng cáo FPT Play** | **personalDNSfilter** v1.50.61.5 chạy ngầm cục bộ (`tun0`), chặn sạch banner khởi động và pre-roll video ads |

---

## 2. File & Tài Nguyên Được Đóng Gói Sẵn Trong Snapshot

Thư mục này hoạt động hoàn toàn độc lập và có thể khôi phục offline kể cả khi không có mạng:

* `apps/CleanYourTV_v2.3_release.apk`: File APK CleanYourTV đã biên dịch kèm cấu hình 4 Dock app chuẩn.
* `apps/SmartTube_v32.68_armeabi-v7a.apk`: File APK SmartTube chính thức đã xác thực MD5.
* `config/debug.keystore`: Keystore số ký ứng dụng cố định.
* `config/disabled_packages.txt`: Danh sách đầy đủ 35 gói cần tắt.
* `config/enabled_packages.txt`: Danh sách các gói hệ thống được giữ lại.
* `config/settings_*.txt`: Toàn bộ cấu hình hệ thống (global, secure, system).
* `metadata.json`: Bản ghi metadata chi tiết.

---

## 3. Cách Khôi Phục (Rollback) Về Bản Snapshot Này

Bất cứ lúc nào TV gặp lỗi, cập nhật nhầm hoặc bạn cài thêm app làm thay đổi cấu hình, chỉ cần mở terminal trên máy tính và chạy **duy nhất 1 lệnh**:

```bash
cd /Users/khanhkd1/.gemini/antigravity/scratch/cleanyourtv
./rollback_to_snapshot.sh
```

### Script sẽ tự động thực hiện:
1. Kết nối tới TV qua ADB (`192.168.1.192:5555`).
2. Kiểm tra CleanYourTV (tự động cài lại nếu thiếu).
3. Kiểm tra SmartTube (tự động cài lại nếu thiếu).
4. Áp dụng lại danh sách tắt 35 gói rác & Netflix.
5. Bảo đảm các dịch vụ cốt lõi (Trợ lý Google, Live TV/HDMI) luôn bật.
6. Thiết lập Home mặc định, Accessibility Service và AdGuard Private DNS.
7. Bật màn hình, trở về Home và chụp ảnh màn hình lưu vào `rollback_latest_verify.png`.

---

## 4. Cách Kiểm Tra Nhanh Trạng Thái TV (Không Thay Đổi Cấu Hình)

Để kiểm tra xem TV có đang ở đúng trạng thái snapshot hay không:

```bash
cd /Users/khanhkd1/.gemini/antigravity/scratch/cleanyourtv
./verify_tv_state.sh
```

Lệnh này sẽ in ra trạng thái các ứng dụng chính, dịch vụ trợ năng, trạng thái Netflix và chụp ảnh màn hình TV lưu về `verify_screen.png`.

---

## 5. Quay Về Giao Diện Gốc Google TV (Stock Restore)

Nếu bạn muốn huỷ bỏ mọi tuỳ biến và quay lại giao diện gốc Google TV 100%:

```bash
cd /Users/khanhkd1/.gemini/antigravity/scratch/cleanyourtv
./backup/sony-kd-65x80l/restore.sh
```

---

## 6. Quản Lý Bộ Lọc Chặn Quảng Cáo FPT Play (personalDNSfilter)

personalDNSfilter hoạt động như một VPN cục bộ cực nhẹ (~25MB RAM, 0% CPU lúc nghỉ) trên TV để lọc DNS và sinkhole các tên miền quảng cáo (`d.adsplay.net`, `ads-cdn.fptplay.net`, `log.adsplay.net`,...). Khi FPT Play gọi quảng cáo đầu video, do không kết nối được tới server quảng cáo, ExoPlayer lập tức bỏ qua và phát video ngay lập tức mà không phải chờ 15–30s.

Để kiểm tra hoặc quản lý personalDNSfilter từ máy tính:

```bash
cd /Users/khanhkd1/.gemini/antigravity/scratch/cleanyourtv

# Kiểm tra trạng thái và interface tun0
./tools/manage_dnsfilter.sh status

# Kiểm tra độ phân giải tên miền quảng cáo vs tên miền thường
./tools/manage_dnsfilter.sh test

# Khởi động lại hoặc cập nhật bộ quy tắc mới
./tools/manage_dnsfilter.sh restart
./tools/manage_dnsfilter.sh push-rules
```

