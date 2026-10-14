# Khuôn sinh-tep — tạo tệp Word / Excel, viết cho OpenClaw 2026.9.9

Agent tạo tệp `.docx` (tiêu đề, đoạn, gạch đầu dòng, bảng) và `.xlsx` (nhiều trang, mỗi trang một bảng) rồi đưa cho người
dùng tải về ngay trong cuộc trò chuyện. Repo đã chạy cách này ở `ws-vsfc-doc-agent` (bảng, tệp nhân viên nhờ làm) và
`ws-ntt-pctsv-manager` (xuất kế hoạch .docx).

## Áp khuôn

`ce_capability_add({ws, capability: "sinh-tep"})`. Không có chỗ CE_FILL, không lệnh con.
- Plugin của agent thêm hai tool: `<prefix>_tao_docx({ten, khoi})` và `<prefix>_tao_xlsx({ten, trang})`.
- Thư viện `docx` (Word) và `fflate` (nén zip cho Excel) vào `devDependencies` của plugin (trường `phu_thuoc` của khuôn):
  `ce_build` cài rồi esbuild gói vào `dist/` — máy chủ không cài gì thêm. Bỏ khuôn ⇒ lần sinh lại bỏ thư viện đi.
- Excel dựng tay (OOXML tối thiểu, chưng cất từ `dung-xlsx.ts` của vsfc), không dùng thư viện bảng tính: ô số JSON ghi là
  SỐ, chuỗi luôn là CHỮ (số điện thoại, mã có số 0 đầu không mất).
- Tệp ghi vào `tep/` trong workspace của agent (`workspace-<ws>/agent-<id>/tep/`), tên an toàn, trùng tên thì `-2`, `-3`.
  Kết quả tool có dòng `MEDIA: <đường dẫn>`: agent ĐẶT NGUYÊN dòng đó, đứng riêng, vào câu trả lời ⇒ khung Chat / kênh
  hiện tệp tải về.

## Viết gì vào prompt của agent (AGENTS.md, mục MỖI LƯỢT)

- Việc nào ra tệp (báo giá, bảng kê, biên bản…) và bố cục: khối nào trước, bảng có những cột nào.
- Số tiền, số lượng viết là SỐ (250000), không viết "250k" hay "250.000" trong ô số; số điện thoại, mã hàng viết là chữ.
- Dữ liệu trong tệp CHỈ lấy từ sổ dữ liệu / tool / người dùng nói — không bịa dòng cho đủ bảng.
- Sau khi tạo: chép dòng `MEDIA:` vào câu trả lời, nói ngắn tệp có gì. Muốn lưu lên Drive: khuôn `composio` (tool
  `drive_luu_chu` lưu chữ / Google Doc; tệp nhị phân chưa có khuôn).

## Giới hạn

- Không mẫu, không phông / lề riêng, không chữ ký số. Văn bản hành chính đúng thể thức (Nghị định 30) là việc của ws riêng
  (`ws-vsfc-doc-agent`), không phải khuôn này.
- Trần một lượt: 2.000 khối, 5.000 dòng bảng.
- Tệp nằm trên máy của agent, không tự dọn: tệp cũ cần xoá thì nhờ người dùng nói.

## Ws mẫu

`use-case/ws-vsfc-doc-agent` — `agent-vanthu/plugins/vsfc-vanthu/src/tep-lam/` (dung-docx.ts, dung-xlsx.ts). Bẫy:
`bay.md` §Tệp và ảnh.
