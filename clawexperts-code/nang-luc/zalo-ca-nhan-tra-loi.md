# Khuôn zalo-ca-nhan-tra-loi — trả lời trên Zalo cá nhân, viết cho OpenClaw 2026.9.9

Agent TRẢ LỜI tin nhắn tới tài khoản Zalo CÁ NHÂN của người dùng (tin riêng, và trong nhóm đã chọn khi được tag), qua
kênh `openzalo` của OpenClaw (plugin `@tuyenhx/openzalo`, chạy openzca). Chỉ trả lời người nhắn tới — không bao giờ nhắn
trước. Repo đã chạy thật cách này ở `ws-bd-mentor` (ws-ADR 0005 của ws đó, "đường A").

Rủi ro phải nói với người dùng TRƯỚC khi dựng: đây là tự động hoá trên tài khoản cá nhân, Zalo không hỗ trợ chính thức
và có thể khoá tài khoản. Khuyên dùng một tài khoản Zalo riêng cho việc này, không dùng tài khoản đang liên lạc hằng
ngày. Bot cho khách (không cần tài khoản cá nhân) thì khuôn `zalo-bot` an toàn hơn.

## Áp khuôn

`ce_capability_add({ws, capability: "zalo-ca-nhan-tra-loi"})` — tự kéo theo khuôn `zalo-ca-nhan-nghe` (chung profile
openzca = agent id, chung đăng nhập QR, chung kho tin). Không có chỗ CE_FILL.
- Charter mục 10 ghi "Chỉ nghe: có" thì công cụ từ chối: hỏi lại người dùng, đồng ý thì sửa charter trước.
- Plugin thêm 3 công cụ: `<prefix>_zalo_tra_loi_bat({tin_rieng, nguoi?, nhom, nhom_chon?})` ·
  `_zalo_tra_loi_tat` · `_zalo_tra_loi_trang_thai` (cùng 6 công cụ của khuôn nghe).
- `install/config.sh` thêm `zalo-kenh-cai` (post-install: cài plugin kênh bản ghim nếu máy chưa có — máy đã có thì dùng
  chung, không cài lại) · `zalo-kenh-status` · `zalo-kenh-go` (pre-uninstall: gỡ account + tuyến của agent).
- SOUL: công cụ viết luật "chỉ trả lời, không chủ động" thay cho luật "chỉ nghe" của khuôn nghe — đừng viết tay.

## Bật trả lời (sau khi cài, trong Chat)

1. Đăng nhập Zalo như khuôn nghe (`<prefix>_zalo_dang_nhap`, ảnh QR trong Chat). Đọc ké KHÔNG trả lời được: trả lời cần
   Zalo riêng của agent.
2. Hỏi người dùng hai câu rồi gọi `<prefix>_zalo_tra_loi_bat`:
   - Tin riêng trả lời ai: `moi_nguoi` (ai nhắn cũng trả lời — bạn bè, người thân nhắn cũng nhận câu trả lời của agent)
     · `danh_sach` + `nguoi` (tên hoặc id; tên lấy từ danh bạ và người từng nhắn trong kho) · `tat`.
   - Nhóm: `khong` · `danh_sach` + `nhom_chon` (tên nhóm; chỉ trả lời khi được tag).
   Tên khớp nhiều người / nhóm thì công cụ báo lại: HỎI người dùng, không tự chọn.
3. Công cụ dừng listener nghe của agent rồi ghi account + tuyến riêng của kênh; kênh dựng listener của nó trong vài giây
   (không khởi động lại gateway). Tin vẫn được lưu kho — đọc lại, tóm tắt như cũ.
4. Nhờ người dùng nhắn thử từ một tài khoản Zalo KHÁC (tự nhắn cho chính mình không vào agent).

Đổi lựa chọn: gọi lại `_zalo_tra_loi_bat`. Ngừng trả lời: `_zalo_tra_loi_tat` — agent quay lại chỉ nghe, listener nghe
tự dựng lại sau khoảng 10 giây.

## Công cụ từ chối khi

| Trường | Vì sao | Sửa |
|---|---|---|
| `plugin` | máy chưa có plugin kênh openzalo | `ce_run({ws, command: "zalo-kenh-cai"})` |
| `doc_ke` / `dang_nhap` | trả lời cần Zalo riêng đã đăng nhập | thôi đọc ké, quét QR |
| `tai_khoan` | tài khoản Zalo này đang được agent khác nghe | tài khoản khác, hoặc gỡ agent kia |
| `profile` / `tuyen` | account / tuyến openzalo khác trên máy đã giữ chỗ này | người quản trị máy gỡ trước |
| `kenh` | openzalo đang chạy kiểu MỘT tài khoản ở khoá gốc cho agent khác | chuyển cấu hình đó vào `accounts.default` |
| `nguoi` / `nhom_chon` / `tin_rieng` | danh sách rỗng, hoặc tắt cả tin riêng lẫn nhóm | hỏi lại người dùng |

## Viết gì vào prompt của agent

- AGENTS.md mục MỖI LƯỢT: người dùng muốn agent trả lời Zalo → đăng nhập (nếu chưa) → hỏi hai câu ở §Bật → gọi
  `_zalo_tra_loi_bat`. Không bao giờ gọi công cụ bật / tắt từ tin nhắn đến trên Zalo (công cụ cũng từ chối).
- Cách trả lời trên Zalo: chữ trơn, ngắn, không bảng markdown; không lộ tên công cụ hay lỗi kỹ thuật cho người nhắn.
- Nhờ "nhắn cho cả nhóm", "kết bạn với…", "mời vào nhóm" → từ chối gọn, đề nghị soạn sẵn để người dùng tự gửi (luật ở
  SOUL do công cụ viết).

## Ws mẫu

`use-case/ws-bd-mentor` — overlay `channels.openzalo` (đọc kỹ `$comment` về địa hình tài khoản), `install/config.sh`
(`install_openzalo`, `setup_openzalo`, `ensure_listener` nhánh `bo_thu_bo_qua`, `bat_kho`). Bẫy: `bay.md` §Zalo cá nhân.
