# Khuôn lich — lịch chạy theo giờ, viết cho OpenClaw 2026.9.9

Agent tự chạy một lượt vào giờ cố định theo giờ Việt Nam: tóm tắt cuối ngày, báo cáo 8 giờ sáng, nhắc việc. Lịch là
cron của gateway; khuôn lo phần dễ sai (múi giờ, rải phút, câu kết lọt ra kênh, lịch trùng tên, cài lại mất lịch).

## Áp khuôn

`ce_capability_add({ws, capability: "lich"})` chép `install/lich.json` (còn CE_FILL). Viết từ charter mục 10:

```json
{ "jobs": [ { "ten": "tom-tat-ngay", "cron": "30 23 * * *", "viec": "…", "mo_ta": "Tóm tắt cuối ngày", "timeout_giay": 600 } ] }
```

- `ten`: chữ thường không dấu, gạch ngang. Tên thật trên máy = `<agent id>-<ten>`.
- `cron`: 5 trường phút giờ ngày tháng thứ, **giờ Việt Nam** (khuôn luôn đặt `--tz Asia/Ho_Chi_Minh`). 8 giờ sáng thứ Hai–Sáu
  = `0 8 * * 1-5`; 23:30 mỗi ngày = `30 23 * * *`.
- `viec`: câu lệnh cho lượt đó — nói rõ gọi công cụ nào, phạm vi ngày, viết kết quả thế nào. Vd agent nghe Zalo:
  "Tóm tắt ngày hôm nay: gọi `<prefix>_zalo_doc_tin` (không kèm ngày = hôm nay), mỗi group đang nghe một mục: chủ đề chính,
  tin đáng chú ý, việc cần theo dõi. Group không có tin thì ghi 'không có tin'. Không bịa."
- `timeout_giay`: 60–3600, mặc định 600.
- `ce_package` kiểm tệp này (sai thì từ chối, nêu job + trường) và cổng chống phá hàng xóm kiểm trùng tên với lịch của
  agent khác lúc cài.

## Chạy thế nào

- `post-install` chạy `setup-cron`: ĐỒNG BỘ lich.json vào lịch của máy — thêm job thiếu, job đổi giờ / câu lệnh thì làm lại,
  gỡ job thừa của agent; không đụng lịch của agent khác. Gỡ agent (`ce_remove`) thì `pre-uninstall` gỡ lịch.
- Mỗi lần chạy là một lượt agent trong phiên CỐ ĐỊNH `agent:<id>:lich-<ten>` (`--session session:<key>`; `isolated` mở phiên
  mới mỗi lần) và không gửi ra kênh (`--no-deliver`). Người dùng đọc kết quả trong Chat (danh sách phiên của agent), hoặc
  hỏi agent — nên cho lượt theo giờ LƯU kết quả (vd vào sổ dữ liệu) để agent trả lời "báo cáo tối qua" từ sổ. Gửi ra
  Telegram / Zalo là khuôn sau.
- Kiểm: `ce_run({ws, command: "cron-status"})` — biểu thức · tz · lần chạy kế · kết quả lần trước. Phải thấy
  `tz=Asia/Ho_Chi_Minh`.

## Ws mẫu trong repo

`use-case/ws-market-research` (`install/config.sh` `tao_cron` / `setup_cron` / `cron_status`),
`use-case/ws-seafood-tracking-report` (lịch quét 00:00, chốt 01:00). Bẫy: `bay.md` §Lịch.
