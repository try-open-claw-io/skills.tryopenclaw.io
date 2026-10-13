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
   Cần ra: một dòng việc chính đo được + người nhắn + nơi họ nhắn (câu 4).
   Người dùng đã nói kênh (Zalo, Telegram…), lịch hay ứng dụng trong câu trả lời → ghi nhận luôn,
   không hỏi lại ở các câu tuỳ chọn.

2. **DỮ LIỆU** — "Agent cần nhớ những gì? Một <đơn / ca làm / khách…> gồm những thông tin nào?"
   Đưa gợi ý mặc định theo loại việc (bảng dưới). Hỏi kèm: dữ liệu có sẵn ở đâu không — Google
   Sheets đã kết nối, file, hay gõ trong chat?
   Cần ra: danh sách trường + nguồn ⇒ biết có cần chỗ lưu dữ liệu (plugin), connector, secret không.

3. **VÍ DỤ HỘI THOẠI** — "Cho tôi một ví dụ: bạn nhắn gì, và muốn agent trả lời thế nào?"
   Câu quan trọng nhất: ví dụ sẽ thành kịch bản thử. Lấy 1–3 ví dụ. Người dùng bí → đề xuất 2
   ví dụ để họ chọn hoặc sửa; họ xác nhận thì tính là ví dụ của họ.

## Câu tuỳ chọn — chỉ hỏi khi cần

4. **KÊNH** — chỉ khi câu 1 chưa rõ, hoặc người nhắn là khách / nhân viên: "Mọi người nhắn agent ở đâu —
   trong Chat của ClawExperts, Zalo cá nhân của bạn, Zalo Bot, hay bot Telegram? Agent trả lời, hay chỉ nghe?"
   Gợi ý theo người nhắn: chỉ bạn → Chat; khách → kênh khách đang dùng.
   - Zalo cá nhân: agent dùng tài khoản Zalo của bạn (đăng nhập bằng mã QR ngay trong Chat). Hỏi thêm: nghe những
     group / người nào; "chỉ nghe" thì agent không bao giờ gửi tin.
   - Zalo Bot, Telegram: cần token bot (hỏi TÊN bot, KHÔNG hỏi token — token nhập sau khi cài).
   - Facebook Messenger: đang làm, chưa có sẵn — nói thật, đề nghị Zalo hay Telegram trong lúc chờ.
   Ghi vào charter mục "Năng lực cần". Tài khoản Zalo / bot đã có agent khác trên máy giữ → ghi chú, lúc dựng
   công cụ sẽ báo và đưa cách khác (đọc ké), không giành.
5. **KHÔNG BAO GIỜ LÀM** — "Có việc gì agent tuyệt đối không được làm không?" Gợi ý theo loại
   việc. Người dùng không nghĩ ra → đề xuất 1–2 dòng, ghi vào "Giả định tôi tự chọn".
6. **TÊN & GIỌNG** — "Đặt tên agent là gì, xưng hô thế nào?" Gợi ý: tên theo việc ("Sổ Đơn"),
   xưng "em" gọi "anh/chị".
7. **DỊCH VỤ NGOÀI** — chỉ khi câu 2 cho thấy cần (Google Sheets, Drive, Gmail, một API có key, một MCP
   server…). Hỏi cần app hay dịch vụ nào, đọc hay ghi. KHÔNG hỏi giá trị key: key được nhập sau khi agent đã cài.
8. **NHỊP CHỦ ĐỘNG** — chỉ khi việc có lịch ("nhắc chấm công 8 giờ", "tóm tắt cuối ngày", "báo cáo sáng"):
   "Agent tự chạy lúc mấy giờ (giờ Việt Nam), và gửi kết quả đi đâu — Chat, Telegram hay Zalo?" Ghi vào
   "Năng lực cần".

## Mặc định theo loại việc thường gặp

| Loại | Trường dữ liệu gợi ý | Không bao giờ làm (gợi ý) |
|---|---|---|
| Sổ đơn hàng | tên khách · số điện thoại · món · số lượng · giá · ngày giao · trạng thái | xoá hay sửa đơn khi chưa hỏi lại |
| Chấm công | người · ngày · giờ vào · giờ ra · ghi chú | sửa giờ công của người khác |
| Tra cứu (bảng giá, quy định) | tài liệu nguồn · ai cập nhật, cập nhật thế nào | trả lời ngoài tài liệu như thể chắc chắn |
| Nhắc việc | việc · hạn · người phụ trách | tự đổi hạn khi chưa được bảo |

## Khi nào dừng

Đủ khi viết được: việc chính đo được · người nhắn · nơi nhắn (Chat hay kênh nào) · trường dữ liệu + nguồn ·
ít nhất một ví dụ hội thoại người dùng đưa hoặc đã xác nhận · ít nhất một dòng "không bao giờ làm". Đủ thì
sang charter, kể cả mới hỏi 3 câu. Trần vẫn là 7 câu: câu tuỳ chọn nào không cần thì bỏ.

Chỉ một việc chưa làm được: màn hình riêng (dashboard) cho agent. Người dùng xin → nói thật một câu, ghi vào
charter mục "Chưa làm được trong bản này", phỏng vấn tiếp phần còn lại.
