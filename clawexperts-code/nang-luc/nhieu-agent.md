# Khuôn nhieu-agent — agent điều phối + agent chuyên trách, viết cho OpenClaw 2026.9.9

Một agent ĐIỀU PHỐI (agent chính của project) nói chuyện với người dùng và chuyển từng việc cho agent CHUYÊN TRÁCH cùng nhóm
(kế toán, kho, chăm sóc khách…), rồi trả lời bằng kết quả của agent đó. Repo đã chạy cách này ở `ws-ntt-pctsv`
(một trợ lý chung + bốn trợ lý theo tổ).

Dùng khi charter có nhiều mảng việc khác hẳn nhau (mỗi mảng một bộ luật, giọng, dữ liệu riêng) mà nhồi vào một prompt thì
lẫn. Một mảng việc ⇒ một agent là đủ; đừng tách cho có.

## Dựng

`ce_peer_add({ws, vai, ten, viec})` — mỗi agent chuyên trách một lần:
- `vai`: tên ngắn không dấu 2–11 ký tự (vd `ke-toan`). Agent id = `<id agent chính>--<vai>` (hai gạch: không bao giờ trùng
  agent của project khác).
- Dựng `agent-<id>--<vai>/` (SOUL / IDENTITY / USER / AGENTS / HEARTBEAT — chỗ CE_FILL bạn viết theo charter), entry riêng
  trong overlay (`minimal` + `read`), ghi `install/peers.json`; lần đầu áp khuôn `nhieu-agent` ⇒ agent chính có
  `sessions_send`.
- AGENTS.md của agent chính có mục **"Agent cùng nhóm"** SINH từ peers.json mỗi lần đóng gói (tên, agentId, việc, cách gọi
  `sessions_send`) — đừng viết tay mục đó; sửa việc của một agent chuyên trách thì sửa peers.json rồi đóng gói lại.
- `install.sh` của nền tảng đăng ký mọi agent của Bundle; gỡ agent chính là gỡ cả nhóm.

## Viết gì vào prompt

- Agent chuyên trách: việc của nó, luật riêng, cách trả kết quả (ngắn, đủ dữ kiện để điều phối chép lại). Nó KHÔNG nói
  chuyện thẳng với người dùng và không gọi agent khác.
- Agent chính (mục MỖI LƯỢT): khi nào tự làm, khi nào chuyển — chép NGUYÊN yêu cầu kèm dữ kiện người dùng đã nói vào
  `message` (agent chuyên trách không thấy cuộc trò chuyện của người dùng).
- Agent chuyên trách KHÔNG thấy tool plugin của agent chính (tool plugin chỉ trả cho agent chính). Việc cần sổ dữ liệu /
  kênh / lịch thì để agent chính làm, hay dựng agent riêng.

## Ws mẫu

`use-case/ws-ntt-pctsv` — `agent-ntt-pctsv/` (trợ lý chung) + `agent-ntt-pctsv-yte/`… (trợ lý tổ); tài liệu
`doc/ws-ntt-pctsv/multi-agent-per-to.md`. Bẫy: `bay.md` §Nhiều agent.
