# Kịch bản thử agent — viết cho OpenClaw 2026.9.7

Kịch bản thử là hội thoại mẫu chạy trên agent THẬT, rồi chấm đạt/trượt. Bundle mang kịch bản theo, nên người
nhận agent cũng chạy được: `node install/eval.mjs` trong thư mục cài của agent.

## Tệp và schema

`test/scenarios/<slug>.yaml` trong project. Cùng schema với bộ chạy eval của nền tảng:

```yaml
agent: binhnt-so-don-hang            # bắt buộc: đúng agent id
scenarios:                           # bắt buộc: danh sách không rỗng
  - id: ghi-don-co-xac-nhan          # bắt buộc: duy nhất, chữ thường không dấu, gạch ngang
    role: owner                      # tuỳ chọn, mặc định "customer"; agent cá nhân dùng owner
    turns:                           # bắt buộc: mỗi phần tử là MỘT lời người dùng nhắn, theo thứ tự
      - "Ghi đơn Lan 0900000001 áo sơ mi trắng size M 2 cái 250k"
      - "đúng rồi"
    tools_expected: [don_them]       # tuỳ chọn: phần cuối tên tool PHẢI được gọi
    tools_forbidden: [don_xoa]       # tuỳ chọn: phần cuối tên tool KHÔNG được gọi
    rubric: |                        # tuỳ chọn nhưng nên có: người chấm đọc để chấm câu trả lời
      - Lượt 1: nhắc lại đủ đơn, hỏi xác nhận, CHƯA lưu
      - Lượt 2: lưu đơn, nói đã lưu kèm số #
```

Tệp sai schema (thiếu `agent`, `id`, `turns`, hay `turns` có phần tử không phải chuỗi) thì bộ chạy dừng
ngay khi đọc, không chạy ca nào.

## Viết ca từ charter

- Mỗi ví dụ hội thoại ở charter mục 7 thành ít nhất một ca. GHI LẠI ví dụ, không bịa việc mới.
- Ví dụ có bước xác nhận thì thêm lượt xác nhận ("đúng rồi", "ok").
- Agent có sổ dữ liệu: ca lưu → `tools_expected: [<loại>_them]`; ca hỏi "bao nhiêu / tổng" →
  `[<loại>_tong]`; ca tìm → `[<loại>_tim]`. Agent không có sổ: bỏ hẳn `tools_expected` / `tools_forbidden`.
- Nên có một ca "chưa xác nhận thì không lưu": một lượt nhắn đơn, `tools_forbidden: [<loại>_them]`.
- Giữ nguyên hai ca có sẵn: `ban-lam-duoc-gi` ("bạn làm được gì?") và `viec-chua-co` ("bạn trả lời khách
  trên Zalo được không?").
- Tên, số điện thoại trong kịch bản là GIẢ (vd 0900000001). Không chép dữ liệu thật của khách.
- Kịch bản là nguồn: sửa kịch bản thì đóng gói và cài lại như mọi lần sửa.

## Chạy

- Trong CE Code: chỉ qua `ce_test` (chạy `install/eval.mjs` của bản đang cài). `only: [...]` để chạy vài ca.
- Người nhận agent: trong thư mục `~/.openclaw/workspace-<ws>/`, chạy
  `node install/eval.mjs [--only ca-1,ca-2] [--out /tmp/eval.md]`.
- Mỗi ca chạy trong một phiên chat MỚI; các lượt trong ca nối tiếp nhau trong cùng phiên. Mỗi lượt có thể
  mất tới một phút hoặc hơn.
- Thử chạy trên agent THẬT. Agent có sổ dữ liệu thì ca lưu GHI vào sổ thật, nằm lẫn với dữ liệu thật. Vì
  vậy `ce_test` dừng ở 🟡 để hỏi người dùng trước; chỉ chạy tiếp với `confirm_writes: true` khi họ đồng ý.

## Chấm

Bộ chạy in hội thoại, tool đã gọi ở từng lượt, và kết luận phần tool (✅/❌) của từng ca. Bộ chạy không tự
chấm câu chữ — người chấm (CE Code, hoặc người) đọc rubric.

- **ĐẠT** khi phần tool ✅ (hoặc ca không khai tool) VÀ câu trả lời khớp rubric.
- **TRƯỢT** trong mọi trường hợp khác. Phần tool ❌ là trượt, dù câu trả lời nghe ổn: agent nói "đã lưu"
  mà không gọi `…_them` là lỗi nặng nhất.
- Kết bằng "x/y ca đạt". Có ca trượt thì đề nghị cách sửa, không tự sửa khi người dùng chưa đồng ý. Ca có
  ghi thì nhắc người dùng các bản ghi thử đang nằm trong sổ.

## Ca thử tốt là ca có thể trượt

Một ca không bao giờ trượt thì không đo gì. Trước khi tin một ca xanh, hỏi: nếu agent làm sai đúng chỗ này
thì ca có đỏ không? Ví dụ: ca "bạn làm được gì?" chỉ có nghĩa khi rubric đòi đúng các việc của Khối 1 — rubric
"trả lời lịch sự" thì agent bịa năng lực vẫn đạt.
