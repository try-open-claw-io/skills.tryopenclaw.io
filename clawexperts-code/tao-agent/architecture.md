# Kiến trúc nền tảng — viết cho OpenClaw 2026.9.9

Đọc khi: phỏng vấn gặp yêu cầu vượt khả năng của agent; người dùng hỏi "sao agent không làm được X"; trước
khi định đụng vào bất cứ thứ gì ngoài `projects/` của CE Code.

## Các lớp của ClawExperts

| Lớp | Là gì | Personal Agent Chat có dùng? |
|---|---|---|
| **Platform-FE** | Web app ClawExperts: Chat, Settings → Ứng dụng, Terminal, trang Agents, Marketplace | Người dùng chat với agent qua đây. Agent không sửa được gì ở đây. |
| **Platform-BE** | Quản lý instance, danh mục use-case, cài use-case từ Marketplace, đẩy cấu hình ứng dụng (connector) vào instance | Không. Personal Agent Chat cài và chia sẻ hoàn toàn ngoài BE (xem "Cài và chia sẻ"). |
| **Instance** | Một container OpenClaw của End-User: gateway + mọi agent + mọi plugin, chung một tiến trình | Agent sống ở đây. |
| **Renderer** | Bộ vẽ Agent Dashboard của use-case từ khối `ui:` trong Bundle | Chưa. Agent có màn hình riêng là pha sau, cần Platform-BE. |
| **UC-Service** | Dịch vụ ngoài nối kênh (Facebook, Zalo…) cho use-case chính chủ | Không. |
| **Connector** | Ứng dụng người dùng đã nối ở Settings → Ứng dụng (Google Sheets, Gmail…), đi qua một MCP server do Platform-BE cấu hình | Bản này chỉ kiểm đã nối hay chưa. |

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
- **Công cụ tối thiểu**: profile `minimal` + `read` + tool plugin của chính nó. Không có `exec`. Chỉ
  CE Code có `exec`.
- **Plugin (tuỳ chọn)**: sổ dữ liệu, khoá dịch vụ, kiểm ứng dụng. Plugin chạy TRONG gateway, chung tiến
  trình với mọi agent: plugin hỏng có thể làm chậm hoặc sập cả instance.

## Không được đụng

- `openclaw.json` ngoài overlay của chính agent (overlay được gộp lúc cài, bằng `apply-overrides.mjs`).
- Agent khác: agent chính chủ của ClawExperts, agent người khác gửi, agent main.
- Kênh (`channels`, `bindings`) và lịch chạy (`cron`) của instance.
- Secret của instance: env, hồ sơ đăng nhập model, token của gateway.
- Trong plugin: `child_process`, `setInterval`, đọc `process.env`, mở tệp ngoài kho của agent.
- Khởi động lại gateway khi người dùng chưa đồng ý: mọi agent trên instance ngừng trả lời một lúc.

## Vì sao bản này chưa làm được một số việc

| Việc | Vì sao chưa |
|---|---|
| Trả lời trên Zalo, Facebook, Telegram | Kênh là tài nguyên chung của instance. Gắn agent vào kênh là sửa định tuyến toàn instance, dễ giành tuyến với agent khác. |
| Tự nhắn theo giờ | Lịch chạy nằm ở mức gateway, chung mọi agent; chưa có khuôn an toàn cho agent tự dựng. |
| Đọc, ghi Google Sheets, Gmail | Connector mới kiểm được đã nối hay chưa; đọc ghi qua connector chưa có khuôn đã kiểm. |
| Màn hình riêng (dashboard) | Platform-FE chỉ vẽ dashboard cho use-case cài qua Platform-BE. |
| Gửi tin, email ra ngoài | Cùng lý do với kênh và connector. |

Người dùng cần những việc này: nói thẳng "bản này chưa làm được", không hứa ngày, không "được nếu…".

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
