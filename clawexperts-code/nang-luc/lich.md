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
- `gui_kenh` (tuỳ chọn): `telegram` | `zalo` | `openzalo` — gửi kết quả ra kênh đó, qua bot / tài khoản RIÊNG của agent.
  Agent phải có khuôn kênh tương ứng (`telegram-bot` / `zalo-bot` / `zalo-ca-nhan-tra-loi`), không thì `ce_package` từ
  chối. Bỏ trống = kết quả nằm trong Chat.
- `ce_package` kiểm tệp này (sai thì từ chối, nêu job + trường) và cổng chống phá hàng xóm kiểm trùng tên với lịch của
  agent khác lúc cài.

## Chạy thế nào

- `post-install` chạy `setup-cron`: ĐỒNG BỘ lich.json vào lịch của máy — thêm job thiếu, job đổi giờ / câu lệnh thì làm lại,
  gỡ job thừa của agent; không đụng lịch của agent khác. Gỡ agent (`ce_remove`) thì `pre-uninstall` gỡ lịch.
- Mỗi lần chạy là một lượt agent trong phiên CỐ ĐỊNH `agent:<id>:lich-<ten>` (`--session session:<key>`; `isolated` mở phiên
  mới mỗi lần). Không có `gui_kenh`: không gửi ra đâu (`--no-deliver`) — người dùng đọc kết quả trong Chat (danh sách phiên
  của agent), hoặc hỏi agent; nên cho lượt theo giờ LƯU kết quả (vd vào sổ dữ liệu) để agent trả lời "báo cáo tối qua".
- Có `gui_kenh`: cron tự gửi câu cuối của lượt ra kênh (`--announce --channel <kênh> --account <agent id> --to <nơi nhận>`)
  — `viec` phải viết sao cho câu cuối CHÍNH LÀ báo cáo (không "Đã xong!").

## Nơi nhận báo cáo (sau khi cài)

CE Code không biết chat id lúc dựng. Nơi nhận đặt bằng mã một lần:
1. Trong Chat với agent, người dùng nói "gửi báo cáo vào Telegram" → agent gọi `<prefix>_lich_noi_nhan({kenh})` → mã 6 số
   (10 phút).
2. Người dùng nhắn bot đúng câu `nơi nhận <mã>` từ chỗ muốn nhận (tin riêng với bot, hay nhóm có bot) → agent gọi
   `<prefix>_lich_xac_nhan({ma})`: lấy đích tin của CHÍNH lượt đó (runtime cấp, không từ tham số), chỉ nhận account của
   agent, ghi `uc-data/<ws>/lich-noi-nhan.json`, chạy lại `setup-cron`.
Mã ngăn người lạ nhắn bot "gửi báo cáo cho tôi" để lấy báo cáo của chủ. Chưa có nơi nhận ⇒ lịch vẫn chạy, kết quả nằm
trong Chat, `setup-cron` in "chưa có nơi nhận".

Viết vào AGENTS.md của agent (mục MỖI LƯỢT): "gửi báo cáo vào <kênh>" → `_lich_noi_nhan` rồi chép hướng dẫn trong kết quả;
tin dạng "nơi nhận <6 số>" → `_lich_xac_nhan`; "chạy thử báo cáo ngay" → `_lich_chay_ngay`.

## Chạy ngay, canh gác

- `<prefix>_lich_chay_ngay({ten})` (trong Chat): `cron run` CHÍNH job đó — cùng phiên, cùng câu lệnh, cùng nơi nhận như
  lịch thật; kết quả tới sau vài phút. Lịch đang chạy dở thì máy từ chối: đợi xong.
- Canh gác KHÔNG qua LLM (plugin, trong gateway, 10 phút một vòng): job thiếu trên máy · bị tắt · lần trước lỗi · quá giờ 15
  phút mà chưa chạy ⇒ báo ra nơi nhận của job (nhắc lại sau 6 giờ; chạy lại bình thường thì báo một lần). Job không gửi ra
  kênh thì không có chỗ báo — chỉ ghi log gateway.
- Kiểm: `ce_run({ws, command: "cron-status"})` — biểu thức · tz · lần chạy kế · kết quả lần trước. Phải thấy
  `tz=Asia/Ho_Chi_Minh`.

## Ws mẫu trong repo

`use-case/ws-market-research` (`install/config.sh` `tao_cron` / `setup_cron` / `cron_status`),
`use-case/ws-seafood-tracking-report` (lịch quét 00:00, chốt 01:00; watchdog `src/watchdog.ts`), `use-case/ws-zalo-assist-agent`
(`src/day-tin.ts` — gửi từ hẹn giờ có tự nạp cfg). Bẫy: `bay.md` §Lịch.
