# Khuôn zalo-ca-nhan-nghe — nghe Zalo cá nhân, viết cho OpenClaw 2026.9.9

Agent dùng tài khoản Zalo CÁ NHÂN của người dùng để NGHE các group họ chọn, lưu tin, đọc lại theo group và ngày giờ
Việt Nam (để trả lời "hôm nay group X nói gì", để tóm tắt). Agent không bao giờ gửi tin ra Zalo — khuôn không có đường
nào làm việc đó. Repo đã chạy thật cách này ở Findy (`ws-market-research`), `ws-bd-mentor`, `ws-zalo-assist-agent`.

## Áp khuôn

`ce_capability_add({ws, capability: "zalo-ca-nhan-nghe"})`. Không có chỗ CE_FILL: khuôn đủ, chỉ cần build.
- Plugin của agent có 6 công cụ: `<prefix>_zalo_dang_nhap` · `_zalo_trang_thai` · `_zalo_nhom` · `_zalo_chon_nhom` ·
  `_zalo_doc_tin` · `_zalo_doc_ke`.
- `install/config.sh` có lệnh con `zalo-cai` · `zalo-listen` · `zalo-status` · `zalo-dung`; `post-install` dựng listener
  (nếu đã đăng nhập), `pre-uninstall` dừng nó.
- Profile openzca = agent id; tài khoản Zalo lưu ở `~/.openzca/profiles/<agent id>/` (KHÔNG nằm trên ổ được giữ khi
  container dựng lại — mất thì quét QR lại).

## Viết gì vào prompt của agent (AGENTS.md, mục MỖI LƯỢT)

1. Người dùng nhờ đăng nhập / chưa đăng nhập → `<prefix>_zalo_dang_nhap`. Kết quả có dòng `MEDIA: <đường ảnh>`: chép
   NGUYÊN dòng đó, đứng riêng một dòng, vào câu trả lời (không bọc code, không chữ đậm) — khung chat biến nó thành ảnh
   QR. Người dùng nói "xong" hay "hết hạn" → gọi lại (không kèm `moi`) để xác nhận hoặc lấy ảnh mới.
2. Sau khi đăng nhập: hỏi người dùng nghe group nào → `<prefix>_zalo_nhom` (tìm không dấu) → `<prefix>_zalo_chon_nhom`.
   Tên khớp nhiều group thì HỎI LẠI, không tự chọn.
3. "Hôm nay group X nói gì", "tóm tắt hôm qua" → `<prefix>_zalo_doc_tin` (ngày theo giờ Việt Nam). CHỈ trả lời từ kết quả
   của công cụ; không có tin thì nói không có.
4. Tài khoản đã có agent khác nghe (công cụ hay lệnh báo "đọc ké") → `<prefix>_zalo_doc_ke` liệt kê, hỏi người dùng, rồi
   chọn. Không đăng nhập lần hai cùng một tài khoản.
5. Agent CHỈ NGHE: công cụ tự viết luật cứng không bao giờ gửi tin vào SOUL (mục "Giới hạn của bản này") khi khuôn này
   đã áp — đừng viết tay. Tóm tắt theo giờ: thêm khuôn `lich` (`lich.md`). Muốn agent trả lời trên chính tài khoản
   này: khuôn `zalo-ca-nhan-tra-loi` (`zalo-ca-nhan-tra-loi.md`) — nó thay luật chỉ nghe.

## Sau khi cài

- `ce_run({ws, command: "zalo-cai"})` cài phần Zalo trước (30–90 giây) nếu muốn người dùng lấy QR nhanh; không cài trước
  thì công cụ đăng nhập tự cài lần đầu.
- `ce_run({ws, command: "zalo-status"})` khi người dùng hỏi agent có đang nghe không.
- Không cần khởi động lại gateway: plugin nạp nóng; listener chạy ngoài gateway (vòng tự dựng lại), plugin dựng lại nó
  mỗi khi gateway lên.
- Tin chỉ có từ lúc đăng nhập: listener không kéo lịch sử cũ.

## Ws mẫu trong repo

`use-case/ws-market-research` — `install/config.sh` (các hàm `zalo_*`), plugin `src/zalo-io.ts`,
`src/modules/zalo-qr.ts`, `zalo-doc-ke.ts`, `zalo-kho.ts`. Bẫy đã gặp: `bay.md`.
