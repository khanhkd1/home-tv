# Hướng Dẫn Quản Lý & Khôi Phục Cho Sony KD-65X80L (Google TV 12)

Thư mục này chứa toàn bộ bản sao lưu hệ thống, script khôi phục và script cài đặt cho tivi **Sony KD-65X80L** (BRAVIA_VH22, Android 12).

---

## 1. Tóm Tắt Trạng Thái Hệ Thống

* **Địa chỉ IP TV:** `192.168.1.192` (kết nối qua dây mạng LAN).
* **DNS chặn quảng cáo:** Đang kích hoạt **AdGuard Private DNS** (`dns.adguard-dns.com`).
* **Launcher hiện tại:** **CleanYourTV** (Phong cách Apple TV tvOS, nền đen tuyền, thanh dock 4 app bo tròn kính mờ, hiệu ứng đèn ambient glow và điều hướng vật lý mượt mà).
* **4 ứng dụng thanh Dock chính:**
  1. **FPT Play** (`net.fptplay.ottbox`)
  2. **SmartTube** (`org.smarttube.stable`) - Ứng dụng xem YouTube không quảng cáo, giao diện TV tối ưu.
  3. **Phim4K** (`com.oxootv.spagreen`)
  4. **Apple TV** (`com.apple.atve.sony.appletv`)
* **Google Assistant & Nút Giọng nói:** Hoạt động hoàn hảo qua phím Mic trên remote Sony (LauncherX được giữ ở chế độ nền để duy trì phiên trợ lý Google Assistant).
* **Live TV & Inputs:** Phím TV/Input trên remote Sony đã được liên kết với `InputKeyService` của CleanYourTV để mở nhanh menu HDMI 1-4, AV và Live TV (`com.sony.dtv.tvx`).

### Danh sách các gói đã vô hiệu hóa an toàn (33 gói):
* **Theo dõi & Nhận diện nội dung Samba TV:** `tv.samba.ssm`, `tv.samba.ssm.ui`
* **Telemetry & Gửi báo cáo lỗi Sony:** `com.qterics.da.product`, `com.sony.dtv.da.service`, `com.sonyericsson.idd.agent`, `com.sony.dtv.sonybugreportsys`, `com.google.android.feedback`
* **Chế độ Demo / Cửa hàng:** `com.sony.dtv.demosupport`, `com.sony.dtv.demosystemsupport`, `com.sony.dtv.multiscreendemo`
* **Quảng cáo, banner khuyến mãi & app rác:** `com.sony.dtv.promos`, `com.sony.dtv.sonyselect`, `com.sony.dtv.sonytab`, `com.sony.dtv.launcherxcustomizer`, `com.sony.dtv.kenhchonloc`, `android.autoinstalls.config.sony.bravia`, `com.sony.dtv.customersupport`, `com.sony.dtv.smarthelp`, `com.google.android.youtube.tvmusic`, `com.google.android.play.games`, `com.amazon.amazonvideo.livingroom`
* **Ứng dụng mặc định của Sony & Google người dùng yêu cầu gỡ:** `com.sony.dtv.ecodashboard` (Eco Dashboard), `com.sony.dtv.timers` (Timer & Đồng hồ), `com.google.android.videos` (Google TV Phim / Play Movies), `com.sony.dtv.smartmediaapp` (Sony Album), `com.sony.dtv.osat.music` (Sony Music), `com.sony.dtv.livingfit` (Living Decor), `com.sony.dtv.notificationcenter` (Trung tâm thông báo), `com.vewd.core.integration.dia` & `com.vewd.core.service` (Kho ứng dụng Vewd)
* **Netflix:** `com.netflix.ninja`, `com.netflix.partner.ncm` (đã vô hiệu hóa theo yêu cầu).

---

## 2. Cách Khôi Phục Nguyên Trạng 100% (Stock Restore)

Nếu bạn muốn quay lại launcher gốc Google TV hoặc hoàn tác mọi thay đổi:

```bash
cd /Users/khanhkd1/.gemini/antigravity/scratch/cleanyourtv
./backup/sony-kd-65x80l/restore.sh
```

Script này sẽ:
1. Bật lại toàn bộ 33 package đã tắt (bao gồm Netflix, các ứng dụng hệ thống Sony, Samba, telemetries).
2. Đặt lại Google TV làm Home mặc định.
3. Đặt lại DNS mạng về chế độ tự động (`opportunistic`).

---

## 3. Cách Bật Lại Từng Ứng Dụng Cụ Thể

Nếu sau này bạn muốn sử dụng lại một app cụ thể nào đó (ví dụ Prime Video hoặc Sony Select), chỉ cần chạy lệnh sau:

```bash
cd /Users/khanhkd1/.gemini/antigravity/scratch/cleanyourtv
TV_HOST=192.168.1.192 tools/venv/bin/python tools/tv.py "pm enable <tên_gói>"
```

*Ví dụ bật lại Prime Video:*
```bash
TV_HOST=192.168.1.192 tools/venv/bin/python tools/tv.py "pm enable com.amazon.amazonvideo.livingroom"
```

---

## 4. Cách Đổi 4 Ứng Dụng Trên Dock Hoặc Đổi Hình Nền (Không Cần Rebuild)

Launcher hỗ trợ cơ chế theme qua file JSON. Bạn có thể thay đổi thứ tự và danh sách 4 app trên Dock bất cứ lúc nào:

1. Tạo file `theme.json` với nội dung mong muốn:
```json
{
  "dock_apps": [
    "com.google.android.youtube.tv",
    "net.fptplay.ottbox",
    "com.oxootv.spagreen",
    "com.netflix.ninja"
  ]
}
```
2. Đẩy cấu hình lên TV:
```bash
TV_HOST=192.168.1.192 tools/venv/bin/python tools/tv.py --push theme.json /data/local/tmp/theme.json
TV_HOST=192.168.1.192 tools/venv/bin/python tools/tv.py 'run-as com.gathin.tvhome cp /data/local/tmp/theme.json files/config.json; rm -f /data/local/tmp/theme.json'
TV_HOST=192.168.1.192 tools/venv/bin/python tools/tv.py 'am force-stop com.gathin.tvhome; input keyevent 3'
```

---

## 5. Bảo Mật Sau Khi Cài Đặt Xong

Để đảm bảo an toàn tuyệt đối cho TV trong mạng LAN:
1. Trên TV, vào **Cài đặt (Settings)** $\rightarrow$ **Hệ thống** $\rightarrow$ **Tùy chọn cho nhà phát triển**.
2. Tắt mục **Gỡ lỗi USB (USB debugging)**.
3. Chọn mục **Thu hồi cấp quyền gỡ lỗi USB** (Revoke USB debugging authorizations).
4. Khởi động lại TV để đóng hoàn toàn cổng 5555.
