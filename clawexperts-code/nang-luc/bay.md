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

## Lịch (cron)

- **Cron chạy theo giờ MÁY CHỦ (UTC)** khi không khai `tz` — lệch 7 tiếng so với giờ người dùng nói.
- **Không `--exact` thì cron rải ngẫu nhiên vài phút** — người dùng đặt 8:00 thấy 8:04.
- **Job isolated mặc định "announce"**: thiếu `--no-deliver` thì câu kết của agent lọt ra kênh cuối cùng.
- **Lượt cron hỏng thì chat vẫn chạy** — đừng suy "agent khoẻ" từ chat. Xem kết quả lần chạy (`cron-status`: lần trước
  lỗi gì). Bản cũ (7.x) từng chết vì thiếu `models.providers` cho model trong `agents.defaults.models`; 9.9 không cần.
- **`--session isolated` mở phiên mới mỗi lần chạy** (kể cả có `--session-key`): phiên cố định là `--session session:<key>`.
- **Agent mới cần auth model**: 9.9 giữ đăng nhập model theo từng agent; máy chưa có "shared auth" thì agent mới trả 401
  (cả chat lẫn lịch) tới khi đăng nhập model cho nó.
- **Container dựng lại / cài lại kiểu local xoá sạch kho cron** ⇒ `post-install` phải đặt lại lịch; luôn đếm lại kèm cột tz.
- **Heartbeat không đọc HEARTBEAT.md** trên 9.x — việc theo giờ đi bằng cron, không bằng heartbeat.

## Telegram

- **Account con `channels.telegram.accounts.<id>` kế thừa MỌI khoá gốc nó không tự đặt** — kể cả `allowFrom`, `groups` của ws
  khác ⇒ đặt tường minh `dmPolicy · allowFrom · groupPolicy · groupAllowFrom · groups`.
- **Khoá gốc `channels.telegram.*` = account mặc định dùng chung**: ws cài sau ghi đè nguyên cụm (đã có ca bot giữ nhật ký
  riêng thành nhận tin của bất kỳ ai). Luôn dùng account mang tên agent + binding `accountId` riêng.
- **Binding thiếu `accountId` = account `default`**, không phải "mọi account" — tin rơi về agent `main` mà không lỗi nào.
- **Trong nhóm, bot chỉ nghe khi được tag** (`requireMention` mặc định true) — muốn khác phải đặt rõ theo nhóm.
- **Lệnh native của plugin (`registerCommand`, `requireAuth: false`) lọt qua tin riêng bất kể `dmPolicy`**, và hiện thành menu
  trên MỌI bot của máy ⇒ handler phải tự chặn agent / account khác. Native command còn **nuốt `continueAgent`**.
- **"Bot không thấy tin nhóm"**: poller kẹt hoặc `requireMention` — kiểm `openclaw channels status --probe` trước khi sửa code.

## Zalo Bot (kênh bundled `zalo`)

- **Ba bề mặt Zalo khác nhau, đừng lẫn**: Zalo Bot (`zalo`, token) · Zalo OA (OAuth + webhook) · Zalo cá nhân (openzca, QR).
- **Nhóm bị bỏ tin IM LẶNG khi `groupPolicy: "disabled"`** — log của nhánh đó chỉ hiện khi bật verbose; `channels status`
  in `in: … ago` là tin đã TỚI gateway (tách ca poller chết khỏi ca cổng vứt).
- **`dmPolicy: "open"` thiếu `allowFrom: ["*"]` là rớt sạch tin riêng**; `groupPolicy: "open"` thì không cần `groupAllowFrom`.
- **`pairing` cho khách là lộ lệnh OpenClaw** ra ngoài — chỉ dùng cho nội bộ.
- **chatId của Zalo Bot là HEX** — bản cũ (6.10) với model đi harness codex giữ câu trả lời riêng tư và bắt dùng tool
  `message`, mà tool đó chỉ nhận id số ⇒ bot câm. Bản 9.x đã vá; gặp lại thì mới tính `messages.visibleReplies` (khoá toàn máy).
- **Không nhận tệp, không có trích dẫn** — trần của Zalo, không phải của OpenClaw.
- **Plugin kênh bundled phải bật**: `plugins.entries.zalo.enabled`; máy có `plugins.allow` thì thêm `zalo` vào đó (post-install
  của khuôn làm) — KHÔNG tự khai `plugins.allow` trong overlay khi máy chưa có allowlist (tắt mọi plugin bundled khác).
