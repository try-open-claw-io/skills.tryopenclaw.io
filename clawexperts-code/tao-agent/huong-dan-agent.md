# Hướng dẫn dùng của agent — viết cho OpenClaw 2026.9.9

Mọi agent CE Code dựng đều có một skill `huong-dan-su-dung`. Người dùng hỏi "bạn làm được gì", "dùng thế
nào", "help", hay hỏi "agent làm được X không" thì agent đọc skill này rồi trả lời. Thiếu nó, agent tự kể
năng lực bằng trí nhớ nền — và hứa cả việc nó không làm được.

## Nằm ở đâu, vì sao

`agent-<id>/skills/huong-dan-su-dung/SKILL.md` — trong workspace của chính agent.

- Skill trong workspace của agent là tầng ưu tiên cao nhất và **chỉ agent đó thấy**. Mọi agent dùng chung
  một tên `huong-dan-su-dung` mà không đè nhau.
- Skill đặt ở `skills.load.extraDirs` thì **mọi agent trên máy** đều thấy. Vì vậy agent CE Code dựng không
  khai `extraDirs`.
- Overlay ghi `agents.entries.<id>.skills` = đúng tên các skill của project. Danh sách không rỗng là tập cuối
  cùng: agent không thấy skill của agent khác, kể cả skill đi kèm OpenClaw.

## Ai viết khối nào

| Khối | Ai viết | Khi nào được viết lại |
|---|---|---|
| Khung, frontmatter, luật đọc | công cụ (`ce_project_create`, hoặc `ce_package` với agent cũ) | không |
| Khối 1 — trả lời mặc định | CE Code, từ charter | khi agent thêm, bớt hay đổi việc |
| Khối 2 — hỏi sâu từng việc | CE Code, từ charter | cùng lúc với Khối 1 |
| Khối Dữ liệu — lưu được gì | công cụ (`ce_build`, `ce_package`) | mỗi lần build hoặc đóng gói |
| Khối Chưa làm được — phần chung | công cụ | mỗi lần đóng gói |
| Khối Chưa làm được — riêng agent | CE Code, từ charter mục 6 và 9 | khi charter đổi |

Chỗ CE Code phải viết mang dấu `CE_FILL`. Còn dấu thì `ce_package` từ chối. Hai khối có chú thích
"Công cụ viết" thì không sửa tay: lần đóng gói sau sẽ ghi đè.

## Viết Khối 1

Một câu giới thiệu (tên + xưng hô theo charter mục 3), 3–6 việc, mỗi việc một dòng "Việc — câu nói mẫu",
kết bằng câu mời hỏi kỹ.

Tốt:
```
Tôi là Sổ Chi Tiêu Gia Đình, trợ lý ghi và tra chi tiêu gia đình cho bạn trong Chat.

Tôi làm được:
- Ghi khoản chi mới — "chi 50k ăn trưa"
- Tìm, sửa hoặc xoá khoản chi đã lưu — "sửa khoản ăn trưa hôm qua thành 60k"
- Tổng hợp chi tiêu theo ngày hoặc hạng mục — "tháng này ăn uống hết bao nhiêu?"

Bạn muốn hỏi kỹ phần nào thì nhắn tên việc đó.
```

Tránh:
- Việc charter không có ("tôi phân tích được xu hướng chi tiêu").
- Tách một quy trình thành nhiều việc ("nhắc lại khoản chi", "lưu sau khi xác nhận" là hai bước của việc ghi).
- Tên công cụ, tên plugin, đường dẫn tệp.
- Việc lưu/tra dữ liệu không khớp Khối Dữ liệu (agent không có sổ mà Khối 1 nói "tôi nhớ đơn của bạn").

## Viết Khối 2

Mỗi việc ở Khối 1 một mục `### <việc>`: người dùng nói thế nào, agent hỏi lại gì khi thiếu thông tin, lúc
nào cần người dùng xác nhận. Lấy từ charter mục 4 (cách làm việc). Charter không nói thì không bịa.

## Khối Chưa làm được

Phần chung (công cụ viết) liệt kê giới hạn của nền tảng ở bản này — chỉ còn màn hình riêng (dashboard) — và
một câu: việc agent này chưa làm (kênh khác, tự nhắn theo giờ, ứng dụng khác) thì nhờ ClawExperts Code thêm. Phần
riêng do CE Code chép từ charter mục 6 (không bao giờ làm) và mục 9 (chưa làm được trong bản này), viết thành câu
nói với người dùng. Không có thì ghi "Không có thêm."

## Để agent thật sự đọc hướng dẫn

Mục "## Hướng dẫn dùng" trong AGENTS.md (công cụ viết) bảo agent **luôn** `read` skill trước khi trả lời,
kể cả khi nó nghĩ mình đã biết. Đo trên OpenClaw 2026.9.7: câu trỏ mềm ("hỏi … → đọc skill") cho 0/3 lần
đọc — agent chép lại AGENTS.md rồi trả lời; câu "LUÔN `read` … trước, kể cả khi nghĩ mình đã biết" cho
12/12 lần đọc trên bốn agent.

Các dòng "chưa làm được" của nền tảng còn được chép ngắn vào SOUL.md ("Giới hạn của bản này"), vì câu hỏi
"…được không?" không phải lúc nào cũng làm agent mở skill. Agent "chỉ nghe" (charter mục 10) có thêm luật không bao
giờ gửi tin trong mục đó.

## Agent dựng trước khi có hướng dẫn

`ce_package` tự tạo khung, từ chối đóng gói và chỉ đúng tệp phải viết. CE Code viết các chỗ `CE_FILL` từ
charter và bộ prompt hiện tại của agent (AGENTS.md, SOUL.md) — không thêm việc mới — rồi đóng gói và cài.
Cùng lần đó công cụ viết lại các mục do nó sở hữu (allowlist skill, mục trỏ hướng dẫn, giới hạn).

Đổi câu chữ trong mục do công cụ sở hữu chỉ tới agent đã cài **ở lần đóng gói kế tiếp** của agent đó.

## Kịch bản thử mặc định

Tệp kịch bản của agent mới có sẵn hai ca, giữ nguyên khi viết các ca khác:
- `ban-lam-duoc-gi` — "bạn làm được gì?": kể đúng Khối 1, không kể việc không làm được.
- `viec-chua-co` — "bạn có màn hình riêng (dashboard) để tôi xem số liệu không?": nói thẳng chưa có, chỉ có trò
  chuyện; không "được nếu…".
