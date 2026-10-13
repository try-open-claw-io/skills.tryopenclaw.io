# Kiến trúc nền tảng — viết cho OpenClaw 2026.9.9

Đọc khi: agent cần kênh, lịch, ứng dụng hay chạy nền; người dùng hỏi agent làm được tới đâu; trước khi định
đụng vào bất cứ thứ gì ngoài `projects/` của CE Code.

## Các lớp của ClawExperts

| Lớp | Là gì | Personal Agent Chat có dùng? |
|---|---|---|
| **Platform-FE** | Web app ClawExperts: Chat, Settings → Ứng dụng, Terminal, trang Agents, Marketplace | Người dùng chat với agent qua đây. Agent không sửa được gì ở đây. |
| **Platform-BE** | Quản lý instance, danh mục use-case, cài use-case từ Marketplace, đẩy cấu hình ứng dụng (connector) vào instance | Không. Personal Agent Chat cài và chia sẻ hoàn toàn ngoài BE (xem "Cài và chia sẻ"). |
| **Instance** | Một container OpenClaw của End-User: gateway + mọi agent + mọi plugin, chung một tiến trình | Agent sống ở đây. |
| **Renderer** | Bộ vẽ Agent Dashboard của use-case từ khối `ui:` trong Bundle | Chưa. Agent có màn hình riêng là pha sau, cần Platform-BE. |
| **UC-Service** | Dịch vụ ngoài nối kênh cho use-case chính chủ | Không. Phần nối kênh của agent cá nhân chạy ngay trong instance (tiến trình nền của plugin). |
| **Connector** | Ứng dụng người dùng đã nối ở Settings → Ứng dụng (Google Sheets, Drive, Gmail…), đi qua một MCP server do Platform-BE cấu hình | Có: đọc ghi qua connector. |

## Bố cục một instance

```
~/.openclaw/
├── openclaw.json                     # cấu hình chung, có token của cả instance — KHÔNG đọc nguyên tệp
├── workspace/                        # agent main của instance
├── workspace-ws-<tác giả>-<slug>/    # bản ĐANG CÀI của một agent — install.sh giải nén ra; không sửa thẳng
│   ├── agent-<id>/                   # AGENTS.md, SOUL.md, IDENTITY.md, USER.md, skills/
│   ├── install/                      # install.sh, uninstall.sh, verify.sh, apply-overrides.mjs, eval.mjs, config.sh
│   ├── dist/<id>.zip                 # plugin đã build (nếu có)
│   ├── bundle.json
│   └── openclaw.ws-<…>.json          # overlay: phần cấu hình của riêng agent này
├── extensions/<plugin-id>/           # plugin đã cài
├── agents/<id>/agent/                # phiên chat của từng agent (SQLite)
└── uc-data/
    ├── ws-clawexperts-code/          # KHO của CE Code: projects/, charters/, builds/, state/ (ngoài workspace)
    └── ws-<tác giả>-<slug>/          # dữ liệu của một agent: data.sqlite, secrets.json (quyền 600)
```

Nguồn agent nằm ở `uc-data/ws-clawexperts-code/projects/<ws>/`. Sửa ở đó rồi đóng gói và cài thành bản
mới. Sửa thẳng trong `workspace-ws-*/` thì không có phiên bản để quay lại, và lần cài sau ghi đè mất.

Workspace của một agent là thư mục `agent-<id>/` trong bản đang cài — kể cả CE Code. Dữ liệu cần sống qua
các lần cài lại (sổ dữ liệu, kho của CE Code) luôn ở `uc-data/`, NGOÀI workspace: OpenClaw 9.9 dọn workspace
mỗi khi xoá agent, `uc-data/` thì không ai dọn. Kho của CE Code còn được chụp ra `backups/clawexperts-code/`;
cài lại mà kho trống thì tự khôi phục từ ảnh chụp.

## Một Personal Agent Chat gồm gì

- **Một agent riêng** (`openclaw agents add`), workspace riêng `agent-<id>/`. OpenClaw 9.x nạp bốn tệp
  prompt: AGENTS.md, SOUL.md, IDENTITY.md, USER.md. Không nạp TOOLS.md — công cụ ghi trong AGENTS.md.
- **Skill riêng** trong `agent-<id>/skills/`, tối thiểu là `huong-dan-su-dung` (xem `huong-dan-agent.md`).
  Overlay có `agents.entries.<id>.skills` liệt kê đúng các skill đó.
- **Công cụ tối thiểu**: profile `minimal` + `read` + tool plugin của chính nó + đúng công cụ các năng lực
  của nó cần. Không có `exec`. Chỉ CE Code có `exec`.
- **Plugin (tuỳ chọn)**: sổ dữ liệu, khoá dịch vụ, ứng dụng, tiến trình nền (nghe Zalo, lịch, watchdog).
  Plugin chạy TRONG gateway, chung tiến trình với mọi agent: plugin hỏng có thể làm chậm hoặc sập cả instance.
- **Năng lực (tuỳ chọn)**: kênh, lịch, ứng dụng, MCP ngoài, nhiều agent, browser, sinh tệp, đọc ảnh quét —
  xem §Năng lực.

## Năng lực

Agent cá nhân làm được mọi loại việc các use-case của ClawExperts đang làm, trừ màn hình riêng (dashboard):

| Năng lực | Cách nền tảng làm |
|---|---|
| Kênh | Zalo cá nhân (openzca: nghe, hoặc trả lời), Zalo Bot (kênh `zalo` có sẵn, nối bằng cấu hình), bot Telegram (account + binding riêng của agent). Facebook Messenger: đang làm. |
| Lịch | Cron của gateway gọi lượt agent theo giờ; luôn khai `tz` Asia/Ho_Chi_Minh (mặc định là giờ máy chủ UTC — lệch 7 giờ). |
| Gửi tin ra ngoài | Lượt lịch hay plugin gửi kết quả ra kênh của chính agent. |
| Ứng dụng | Đọc ghi Google Sheets, Drive, Gmail… qua connector đã nối. |
| MCP ngoài | Khai server MCP bằng cấu hình (`mcp.servers`), không viết tool bọc. |
| Chạy nền | Plugin dùng `child_process`, `setInterval` (vd listener nghe Zalo, watchdog). |
| Khác | Nhiều agent phối hợp, mở trang web (browser), sinh .docx / .xlsx, đọc ảnh quét. |

Mỗi năng lực có khuôn (phần tất định: overlay, lệnh con của `install/config.sh`, nguồn plugin) và bài kiến thức
(cách repo làm, ws mẫu, bẫy đã gặp). Charter ghi năng lực cần ở mục "Năng lực cần".

## Không phá agent khác

Instance là nhà chung: kênh, binding, lịch, plugin allowlist, tài khoản Zalo là tài nguyên chung. Luật:

- `openclaw.json` chỉ đổi qua overlay của chính agent (gộp lúc cài bằng `apply-overrides.mjs`) — không sửa tay, không
  đổi khoá toàn instance ngoài danh sách cho phép.
- Không giành account kênh, binding, bot hay lịch của agent khác. Binding thiếu `accountId` = account `default`.
- Một tài khoản Zalo chỉ một listener: tài khoản đã có agent khác nghe thì đọc ké tin agent kia đang nghe, không
  dựng listener thứ hai (hai listener đá nhau).
- Id plugin, id lịch mang tên agent; không trùng của ws khác.
- Agent khác: agent chính chủ của ClawExperts, agent người khác gửi, agent main — không sửa tệp của chúng.
- Secret của instance (env, hồ sơ đăng nhập model, token của gateway) — không đọc, không in.
- Khởi động lại gateway (cần khi gắn kênh mới, đổi env) chỉ khi người dùng đã đồng ý: mọi agent ngừng trả lời một lúc.
- Trong plugin: không đọc `process.env`, không mở tệp ngoài kho của agent (trừ đúng thứ khuôn năng lực cho phép, vd
  kho tin của openzca, chỉ đọc).

## Cài và chia sẻ

- CE Code đóng gói agent thành **Bundle** (xem `dinh-dang-bundle.md` của skill `sua-agent`) và cài ngay trên máy
  người tạo.
- Chia sẻ: plugin của CE Code phát zip qua một link có token (`/ce-share/<token>/<ws>.zip`); link luôn trả
  bản đang cài trên máy người tạo. Người nhận dán một lệnh vào Terminal:
  `curl -fsSL …/install/oc-install.sh | bash -s <link>` — tải, giải nén vào `~/.openclaw/`, chạy
  `install/install.sh`.
- Gỡ: `bash ~/.openclaw/workspace-<ws>/install/uninstall.sh` trong Terminal (không gỡ được từ web app).
- Cứu khi gateway không lên vì plugin của agent cá nhân: `curl -fsSL …/install/oc-rollback.sh | bash -s -- --safe`.

## Tài liệu đúng bản đang chạy

`/app/docs` trong container (`openclaw` là wrapper gọi `/app/openclaw.mjs`). Ghi chú phát hành:
`/app/docs/releases/<bản>.md` và `index.md`. Playbook này viết cho bản ở dòng đầu; máy chạy bản mới hơn
thì tra `/app/docs` trước.
