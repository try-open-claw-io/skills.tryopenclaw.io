# Mẫu charter — viết cho OpenClaw 2026.9.9

Hai dạng của cùng một nội dung: **tệp** (ghi xuống `charters/<slug>.md`, đầy đủ, là thứ công cụ
dựng đọc sau này) và **bản tóm tắt** (trình trong chat để duyệt). Giữ đúng tên và thứ tự mục.

## Tệp `charters/<slug>.md`

```markdown
# Charter — <Tên agent>

- slug: <slug>
- trạng thái: chờ duyệt            ← duyệt xong đổi thành: đã duyệt <dd/mm HH:MM>
- tạo: <dd/mm/yyyy> bởi ClawExperts Code

## 1. Việc chính
<một dòng, đo được>

## 2. Ai dùng · ở đâu
<ai nhắn với agent> · Chat của ClawExperts

## 3. Tính cách & giọng
- Tên: <tên>
- Xưng hô: <vd em — anh/chị>
- Tính cách: <2–3 tính từ + một câu vì sao>

## 4. Kịch bản việc chính
1. <bước>
2. <bước>
…  (3–6 bước: nhận yêu cầu → làm → xác nhận lại → báo kết quả)

## 5. Dữ liệu
- Lưu: <trường 1> · <trường 2> · …   (hoặc: không lưu gì)
- Nguồn: <gõ trong chat / Google Sheets "<tên>" / …>
- Cần chỗ lưu dữ liệu (plugin): có / không
- Cần connector: <tên app> / không
- Cần secret: <TÊN — lấy ở đâu> / không      ← chỉ tên + chỗ lấy, KHÔNG BAO GIỜ có giá trị

## 6. Không bao giờ làm
- <dòng>

## 7. Ví dụ hội thoại
### Ví dụ 1
- Người dùng: <…>
- Agent: <…>

## 8. Giả định tôi tự chọn
- <thứ CE Code chọn thay người dùng — hoặc: không có>

## 9. Chưa làm được trong bản này
- <vd trả lời khách qua Zalo · tự nhắn lúc 8 giờ — hoặc: không có>
```

## Bản tóm tắt trong chat (≤ ~25 dòng)

```
📋 Charter — <Tên agent>  (charters/<slug>.md)

Việc chính: <một dòng>
Ai dùng: <…>
Giọng: <tên> · xưng <…> · <tính cách>

Kịch bản:
 1. <…>
 2. <…>
 3. <…>

Dữ liệu: <trường…> · nguồn <…> · <cần plugin / connector / secret: …>
Không bao giờ: <…>
Ví dụ: "<người dùng nhắn>" → "<agent trả lời>"

Tôi tự chọn: <…>
Chưa làm được trong bản này: <…>

🟡 Bạn duyệt, hay muốn sửa chỗ nào?
```

Mục 8 và 9 trống thì vẫn in một dòng "không có" — để người dùng thấy rõ là không có, không phải bị quên.
