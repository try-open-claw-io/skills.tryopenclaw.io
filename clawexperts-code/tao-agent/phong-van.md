# Phỏng vấn — hỏi gì, hỏi thế nào — viết cho OpenClaw 2026.9.9

Mục tiêu: đủ để viết charter, không hơn. Người trả lời hiểu việc của họ, không hiểu kỹ thuật.

## Cách hỏi

- Một câu mỗi lượt, bằng ngôn ngữ của việc. Luôn kèm "Gợi ý: …" để họ chỉ cần gõ "ok".
- Ghi tiến độ ở đầu câu: "(câu 2/≈5)".
- Trả lời mơ hồ ("quản lý đơn") → hỏi lại bằng một ví dụ cụ thể, không bằng định nghĩa.
- "Bạn tự quyết" → chọn mặc định hợp lý, ghi vào "Giả định tôi tự chọn". Riêng VIỆC CHÍNH thì
  không tự quyết thay được.

## Ba câu bắt buộc

1. **VIỆC CHÍNH + AI DÙNG** — "Agent này làm việc gì, cho ai? Ai sẽ nhắn với nó: chỉ bạn, nhân
   viên, hay khách?"
   Cần ra: một dòng việc chính đo được + người nhắn.
   Muốn agent trả lời khách qua Zalo, Facebook hay Telegram → vẫn hỏi tiếp bình thường; ghi vào
   charter mục "Chưa làm được trong bản này" và nói thật một câu: bản này agent sống trong Chat
   của ClawExperts.

2. **DỮ LIỆU** — "Agent cần nhớ những gì? Một <đơn / ca làm / khách…> gồm những thông tin nào?"
   Đưa gợi ý mặc định theo loại việc (bảng dưới). Hỏi kèm: dữ liệu có sẵn ở đâu không — Google
   Sheets đã kết nối, file, hay gõ trong chat?
   Cần ra: danh sách trường + nguồn ⇒ biết có cần chỗ lưu dữ liệu (plugin), connector, secret không.

3. **VÍ DỤ HỘI THOẠI** — "Cho tôi một ví dụ: bạn nhắn gì, và muốn agent trả lời thế nào?"
   Câu quan trọng nhất: ví dụ sẽ thành kịch bản thử. Lấy 1–3 ví dụ. Người dùng bí → đề xuất 2
   ví dụ để họ chọn hoặc sửa; họ xác nhận thì tính là ví dụ của họ.

## Câu tuỳ chọn — chỉ hỏi khi cần

4. **KHÔNG BAO GIỜ LÀM** — "Có việc gì agent tuyệt đối không được làm không?" Gợi ý theo loại
   việc. Người dùng không nghĩ ra → đề xuất 1–2 dòng, ghi vào "Giả định tôi tự chọn".
5. **TÊN & GIỌNG** — "Đặt tên agent là gì, xưng hô thế nào?" Gợi ý: tên theo việc ("Sổ Đơn"),
   xưng "em" gọi "anh/chị".
6. **DỊCH VỤ NGOÀI** — chỉ khi câu 2 cho thấy cần (Google Sheets, một API có key…). Hỏi cần app
   hay dịch vụ nào. KHÔNG hỏi giá trị key: key được nhập sau khi agent đã cài.
7. **NHỊP CHỦ ĐỘNG** — chỉ khi việc có lịch ("nhắc chấm công 8 giờ", "báo cáo cuối ngày"):
   "Agent có cần tự nhắn vào giờ cố định không?" Có → ghi vào "Chưa làm được trong bản này".

## Mặc định theo loại việc thường gặp

| Loại | Trường dữ liệu gợi ý | Không bao giờ làm (gợi ý) |
|---|---|---|
| Sổ đơn hàng | tên khách · số điện thoại · món · số lượng · giá · ngày giao · trạng thái | xoá hay sửa đơn khi chưa hỏi lại |
| Chấm công | người · ngày · giờ vào · giờ ra · ghi chú | sửa giờ công của người khác |
| Tra cứu (bảng giá, quy định) | tài liệu nguồn · ai cập nhật, cập nhật thế nào | trả lời ngoài tài liệu như thể chắc chắn |
| Nhắc việc | việc · hạn · người phụ trách | tự đổi hạn khi chưa được bảo |

## Khi nào dừng

Đủ khi viết được: việc chính đo được · người nhắn · trường dữ liệu + nguồn · ít nhất một ví dụ
hội thoại người dùng đưa hoặc đã xác nhận · ít nhất một dòng "không bao giờ làm". Đủ thì sang
charter, kể cả mới hỏi 3 câu.
