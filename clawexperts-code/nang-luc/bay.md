# Bẫy đã gặp — viết cho OpenClaw 2026.9.9

Chưng cất từ sự cố thật của các use-case ClawExperts. Đọc trước khi viết plugin có việc nền hay sửa một khuôn.

## Chung cho mọi plugin

- **`register()` chạy HAI lần** trong gateway (và chạy khi lệnh CLI `openclaw …` nạp plugin). Bộ đếm giờ, listener,
  tiến trình con khởi trong `register()` sẽ nhân đôi. Giành lượt ở mức KHO (tệp khoá trong `uc-data/<ws>/`, hay khoá
  `mkdir` trong config.sh), không bằng biến toàn cục; chỉ khởi việc nền khi `process.title` có "gateway".
- **Ảnh do plugin đưa ra không được host làm sạch.** Trần thật: 1200px mỗi chiều, 5MB. Vượt trần không chỉ hỏng lượt đó
  mà hỏng CẢ các lượt sau (lịch sử phát lại nguyên văn). Tự kiểm cỡ trước khi đưa.
- **Model đọc `content`, không đọc `details`** của kết quả tool: mọi thứ agent cần nói lại hay dùng tiếp phải nằm trong chữ.
- **Ảnh cho NGƯỜI DÙNG xem** đi bằng dòng `MEDIA: <đường tuyệt đối>` đứng riêng trong câu trả lời của agent, tệp đặt trong
  workspace của agent. Ảnh nằm trong kết quả tool chỉ model thấy.
- **`openclaw gateway restart` không có tác dụng trong container** (không systemd) — khởi động lại chỉ qua `ce_restart`.
- **`spawn` lệnh ngoài phải bắt sự kiện `error`** (ENOENT khi chưa cài): lỗi không bắt làm chết cả gateway.

## Zalo cá nhân (openzca)

- **Một tài khoản Zalo, một listener.** Listener thứ hai trên cùng tài khoản đá listener đầu (cả hai chập chờn). Tài khoản
  đã có agent khác nghe ⇒ đọc ké kho của nó, chỉ đọc.
- **Profile mới TẮT kho tin**: thiếu `db enable` thì listener chạy mà kho 0 tin.
- **Listener tự khoá sau khởi động lại**: `listener-owner.json` còn pid cũ, pid được cấp lại cho tiến trình khác ⇒ openzca
  từ chối chính nó mãi, trạng thái vẫn xanh. Gỡ khoá khi pid không phải `openzca … listen` (khuôn đã làm).
- **`db sync` đá listener đang chạy** — không chạy khi listener sống.
- **Mã QR đổi sau 60 giây** (openzca ghi mã mới vào đúng tệp): đưa lại ảnh khi mtime đổi; không ai quét 5 phút thì dừng
  tiến trình đăng nhập (không thì treo mồ côi).
- **Đừng `--raw`** (log nuốt nguyên tin) **và đừng `--supervised`** (tắt retry nội bộ); vòng `while true` bên ngoài là
  bắt buộc (websocket đóng 1000 thì openzca thoát hẳn dù có `--keep-alive`).
- **`npm install -g` trần nhắm /usr/local (root) ⇒ EACCES**: cài vào prefix riêng trong `~/.openclaw`; nghiệm thu bằng
  binary, không tin mã thoát của npm. Stub `xdg-open` để openzca không tự mở ảnh.
- **`grep "openzca listen"` âm tính giả**: dòng lệnh là `node …/openzca --profile <p> listen …`.
- **`~/.openzca` không nằm trên ổ được giữ**: đăng nhập sống qua khởi động lại gateway / container, mất khi container
  dựng lại — quét QR lại.
- **Tin chỉ có từ lúc đăng nhập**: không có lịch sử trước đó.
