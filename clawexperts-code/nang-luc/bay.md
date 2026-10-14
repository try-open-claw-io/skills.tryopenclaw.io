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

Kênh trả lời `openzalo` (khuôn `zalo-ca-nhan-tra-loi`):

- **Ghim `@tuyenhx/openzalo@2026.10.12`**: mọi bản cũ hơn làm gateway OpenClaw ≥ 2026.8.1 THOÁT ở tin Zalo đầu tiên và
  gửi trả lời hỏng (CHANGELOG của plugin). Plugin là của chung máy: đã có thì dùng chung — `--force` đè bản agent khác.
- **Khai `channels.openzalo` khi plugin chưa có ⇒ gateway từ chối khởi động, lặp mãi** (CLI chết theo, không gỡ được
  bằng lệnh). Khuôn không khai kênh trong overlay: account + tuyến ghi lúc chạy, sau khi plugin đã nạp.
- **Account kế thừa mọi khoá gốc `channels.openzalo.*`** — kể cả `allowFrom`, `groups`, `acpx` của ws khác. Ghi tường minh.
- **Khối gốc kiểu MỘT tài khoản** (có `profile` / chính sách ở gốc, không có `accounts`): thêm một account là account ngầm
  `default` biến mất — kênh của agent kia chết im lặng.
- **Listener của kênh là `listen --raw --supervised`**: không `--db` (profile phải `db enable`, không thì kho 0 tin) và
  không `--self` (tin agent gửi không vào kho; tự nhắn cho chính tài khoản đó không vào agent — thử bằng tài khoản khác).
- **Kênh bật thì listener của kênh là listener DUY NHẤT** của profile: listener nghe phải dừng trước và không dựng lại
  (khuôn nghe tự nhường khi thấy account kênh của agent đang bật).
- **`actions` của kênh mặc định BẬT**: thả cảm xúc, sửa / thu hồi, đổi tên / rời nhóm, thêm-bớt người, ghim — trên tài
  khoản cá nhân là hành động chủ động. Khuôn tắt hết.
- **Plugin mang skill `openzca`** dạy dùng CLI (kết bạn, quản trị nhóm…) qua `exec` — agent người dùng không có `exec`.
- **9.9 nạp nóng plugin cài bằng npm** ("Applied in Gateway generation N") — không cần khởi động lại sau `zalo-kenh-cai`.

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
- **Heartbeat không đọc HEARTBEAT.md** trên 9.x — việc theo giờ đi bằng cron, không bằng heartbeat. Đừng khai khối
  `heartbeat` cho agent trong overlay: có một agent khai là CHỈ agent đó còn heartbeat, mọi agent khác trên máy mất.
- **`--announce` thiếu `--account`** ⇒ gửi bằng bot mặc định của máy (bot của agent khác). Luôn kèm account riêng + `--to`.
- **Gửi từ hẹn giờ / việc nền (không có lượt tool)**: `sendDurableMessageBatch` KHÔNG tự điền `cfg` ⇒ trượt mọi lần
  (kênh đọc account từ `undefined`). Tự nạp `getRuntimeConfig()` từ `openclaw/plugin-sdk/config-runtime`.
- **Plugin mở lượt agent ngay**: `api.runtime.subagent.run` phải được gọi (và `await`) TRONG lúc tool còn chạy — gọi sau khi
  tool trả về là "invocation authority expired"; `waitForRun` / `getSessionMessages` chạy nền sau đó cũng bị huỷ (9.9) ⇒
  không lấy được câu cuối để tự gửi. Chạy lại một lịch có sẵn: `openclaw cron run <id>` qua CLI (không gắn với lời gọi tool;
  từ chối khi job đang chạy). `gateway.request` bị chặn với plugin cài từ đường dẫn.
- **Canh gác chạy trong gateway nhân đôi**: `register()` chạy hai lần ⇒ hai bộ hẹn giờ — giành vòng ở mức kho (tệp khoá +
  mốc), không bằng biến trong RAM. Báo động không đi qua LLM: model hỏng thì lượt cron chết, lượt báo động cũng chết.

## Ứng dụng Google (connector Composio)

- **Gọi qua `connector_call_tool {name, arguments}`**: gọi thẳng tên slug thì proxy chạy lời gọi MẶC ĐỊNH với tham số rỗng
  (đo: liệt kê Drive trả cả My Drive thay vì thư mục chọn). Đừng đoán slug: slug bịa trả "Unable to retrieve tool with slug".
- **`tools/list` cắt 20 tool mỗi ứng dụng theo vần** — không phải danh sách gọi được (`GOOGLEDRIVE_CREATE_FILE_FROM_TEXT` nằm
  ngoài mà vẫn gọi được).
- **Bốn dạng kết quả**: JSON-RPC lỗi · ứng dụng CHƯA NỐI = chữ tiếng Anh trơn kèm `isError` (không JSON — bộ bóc nào nuốt
  lỗi parse là báo "trống") · `successful:false` trong JSON · thành công mà thiếu dữ liệu (`_no_id`) = kết nối Google cũ
  hỏng, phải nối lại. Bảng rỗng THẬT vẫn có khoá (`values: []`).
- **Đọc Sheet bằng `GOOGLESHEETS_BATCH_GET` với vùng CÓ BIÊN** (`A1:Z1001`; vùng trần `A:W` trả rỗng), không bằng gviz
  (gviz tự đoán dòng tiêu đề, gộp nhiều dòng thành một — mất dữ liệu im lặng). `gid` trong link = tab người dùng đang xem.
- **Ghi Sheet kiểm bằng ĐỌC LẠI**: có ca Composio báo xong mà không ghi gì. Ghi `USER_ENTERED` thì Google định dạng lại
  số / ngày — so ô có chữ cái, đừng so mọi ô.
- **Tool TẠO MỚI gọi với tham số rỗng là tạo thật** (`GOOGLEDRIVE_CREATE_FILE {}` ⇒ tệp "Untitled"). Kiểm tham số trước.
- **Gmail không có truy vấn ⇒ 20 thư mới nhất CẢ hộp thư** (toàn quảng cáo); mỗi thư ~66.000 ký tự HTML — bóc thẻ, cắt.
- **Connector nối theo INSTANCE**: nối tài khoản Google mới là đổi tài khoản cho mọi agent trên máy. Dữ liệu riêng tư ⇒
  instance riêng.
- Proxy đòi `Accept: application/json, text/event-stream` (thiếu là 406) và tiền tố `Bearer` trong `Authorization`.

## MCP ngoài (`mcp.servers`)

- **Khai bằng config, không viết tool bọc**: OpenClaw biến mọi tool của server thành tool native `<server>__<tool>`.
- **`Authorization` thiếu tiền tố `Bearer`** ⇒ 401 "Invalid JWT form" — trông như khoá sai, mất cả giờ (ws-ce-ops).
- **`mcp.servers` là của CHUNG máy**: agent nào có `bundle-mcp` (profile `full`, `coding`…) cũng thấy tool của server. Agent
  CE Code dựng mở đúng server của nó bằng glob `<tiền tố>-*`; đừng thêm `bundle-mcp`.
- **Tên server bị cắt còn 30 ký tự** trong tên tool (trùng thì thêm `-2`) — đặt tên ngắn, mở đầu bằng tiền tố của agent.
- **url phải có đường dẫn** (`https://host/mcp`, không phải `https://host/`); server stateless trả `GET` 405 là đúng.
- Khoá nằm ở `headers` trong `openclaw.json` (client MCP chỉ đọc khoá từ config) — như token bot; không in ra, không nhắc lại.

## Nhiều agent

- **`sessions_send` bật sẵn từ 9.7** (mọi cặp agent, tầm nhìn `all`). KHÔNG khai `tools.agentToAgent.allow`: khai là CHẶN
  mọi cặp không có tên — kể cả cặp của ws khác trên máy. `sessions_send` không có trong profile `minimal` ⇒ agent chính
  thêm vào `alsoAllow`.
- **Chỉ agent đăng ký ở `agents.list` (peer) dùng được** `sessions_send`; subagent (`sessions_spawn`) bị chặn tool này.
- **Tệp không đi qua `message`** (chỉ chữ): chuyển ĐƯỜNG DẪN tệp, agent kia đọc bằng `read`.
- **Tool plugin hiện với MỌI agent của máy** nếu đăng ký thẳng — khuôn plugin trả tool chỉ cho agent chính (factory trả
  `null` cho agent khác), nên agent chuyên trách không thấy tool đó.
- **Agent mới cần auth model riêng** (9.9): cả nhóm đều 401 tới khi đăng nhập model cho từng agent (hay máy có shared auth).

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
