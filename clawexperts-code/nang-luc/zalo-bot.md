# Khuôn zalo-bot — Zalo Bot riêng của agent, viết cho OpenClaw 2026.9.9

Agent trả lời trên một **Zalo Bot** (Zalo Bot Platform — bot.zaloplatforms.com, token như bot Telegram). KHÁC hẳn Zalo cá
nhân (openzca, khuôn `zalo-ca-nhan-*`) và Zalo OA. Repo đã chạy kênh này ở `ws-ntt-pctsv`, `ws-vsfc-doc-agent`.

## Áp khuôn

`ce_capability_add({ws, capability: "zalo-bot"})`. Không có chỗ CE_FILL. Overlay bật plugin kênh bundled `zalo`
(`plugins.entries.zalo.enabled`). Plugin có `<prefix>_zalo_bot_cai({token, tin_rieng, nhom})` · `_zalo_bot_trang_thai` ·
`_zalo_bot_go` — cùng cách với khuôn `telegram-bot` (chủ dán token trong Chat sau khi cài; account + tuyến riêng ghi lúc
chạy; chống giành bot; chỉ chủ trong Chat).

- **`tin_rieng` theo NGƯỜI nhắn, không theo kênh**: khách ⇒ `moi_nguoi`; nhân viên nội bộ ⇒ `ghep_cap`. KHÔNG BAO GIỜ
  `ghep_cap` cho bot bán hàng: người lạ nhận câu "OpenClaw: access not configured… openclaw pairing approve…" — lộ công cụ
  nội bộ cho khách.
- `nhom`: `khong` · `khi_duoc_tag`.

## Viết gì vào prompt của agent

- Gắn bot: hướng dẫn tạo bot ở bot.zaloplatforms.com, lấy token, dán; gọi `_zalo_bot_cai`. KHÔNG nhắc lại token.
- Tin trên Zalo Bot KHÔNG có phần trích dẫn (người dùng trả lời-trích một tin rồi tag bot: agent chỉ nhận chữ họ gõ) ⇒
  lệnh trống thì HỎI LẠI, đừng đoán từ tin trước.
- Zalo Bot không nhận tệp (chỉ chữ, ảnh, sticker, voice): việc cần tệp đi kênh khác (Drive, Telegram).

## Ws mẫu

`use-case/ws-vsfc-doc-agent` (overlay kênh `zalo`, `install/config.sh install-zalo-plugin`), `use-case/ws-ntt-pctsv`.
Bẫy: `bay.md` §Zalo Bot.
