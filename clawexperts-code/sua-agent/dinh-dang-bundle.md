# Định dạng Bundle — viết cho OpenClaw 2026.9.7

Bundle là MỘT tệp zip chứa trọn một agent, cài được lên bất kỳ instance OpenClaw nào đủ bản. Personal Agent
Chat dùng đúng định dạng của use-case chính chủ trên Marketplace — không có định dạng "cá nhân" riêng.
CE Code đóng gói bằng `ce_package`; đừng tự zip.

## Bố cục (ví dụ thật: agent sổ đơn hàng)

```
workspace-ws-binhnt-so-don-hang/          # MỌI THỨ nằm dưới đúng một thư mục này
├── bundle.json
├── openclaw.ws-binhnt-so-don-hang.json   # overlay
├── .env.ws-binhnt-so-don-hang            # tài liệu biến môi trường — agent cá nhân: không có biến nào
├── agent-binhnt-so-don-hang/
│   ├── AGENTS.md  SOUL.md  IDENTITY.md  USER.md  HEARTBEAT.md
│   └── skills/huong-dan-su-dung/SKILL.md
├── dist/binhnt-so-don-hang.zip           # plugin ĐÃ BUILD (không có nguồn plugin)
├── install/
│   ├── install.sh  uninstall.sh  verify.sh  apply-overrides.mjs  apply-overrides.test.mjs  eval.mjs
│   ├── config.sh                         # của riêng agent
│   └── install-wizard.yaml
├── skills/edit-agent-dashboard/…         # skill chung của nền tảng, chèn lúc đóng gói
└── test/scenarios/so-don-hang.yaml       # kịch bản thử
```

Giải nén tại `~/.openclaw/` là ra đúng `~/.openclaw/workspace-<ws>/`, cạnh `workspace/` của agent main.
Gỡ sạch một agent = xoá đúng thư mục đó (sau khi `uninstall.sh` gỡ đăng ký).

## `bundle.json`

```json
{
  "bundleFormat": 1,
  "workspace": {
    "id": "ws-binhnt-so-don-hang",
    "description": "Nhận thông tin đơn hàng … hỏi xác nhận trước khi người dùng chốt.",
    "openclawMinVersion": "2026.9.7",
    "author": "binhnt",
    "uid": "2f74ce94-7bc3-47b6-a727-207fc478ab0a"
  },
  "package": { "version": "2026.10.09-0216-2" },
  "skills": [
    { "canonicalName": "edit-agent-dashboard", "srcFolder": "skills/edit-agent-dashboard",
      "installPath": "workspace-ws-binhnt-so-don-hang/skills/edit-agent-dashboard" }
  ]
}
```

- `workspace.id` = `ws-<tác giả>-<slug>`. Tên tác giả chọn một lần, dùng cho mọi agent của người đó.
- `workspace.author` có mặt ⇒ đây là agent cá nhân (không phải use-case chính chủ). Lệnh cứu
  `oc-rollback.sh --safe` chỉ tắt plugin của các bundle có `author` khác `clawexperts`.
- `workspace.uid` — căn cước của agent, sinh MỘT lần và giữ qua mọi bản (lưu trong sổ phiên bản của CE Code,
  không trong nguồn, nên quay lại bản trước vẫn giữ). Hai tác giả trùng tên ws thì uid khác nhau: lệnh cài
  dừng thay vì đè agent đang có.
- `openclawMinVersion` — bản OpenClaw đang chạy lúc đóng gói. Máy chạy bản cũ hơn thì lệnh cài dừng.
- `package.version` — `YYYY.MM.DD-HHMM` theo giờ UTC; đóng gói hai lần trong cùng phút thì thêm `-2`, `-3`.
- `skills[]` — chỉ skill ở thư mục `skills/` của bundle. Skill riêng của agent nằm trong `agent-<id>/skills/`
  và đi theo thư mục agent.

## Overlay `openclaw.<ws>.json`

Phần cấu hình của riêng agent này, được gộp vào `openclaw.json` của instance lúc cài. Dạng cấu hình 9.x:

```json
{
  "agents": { "entries": { "binhnt-so-don-hang": {
    "workspace": "/home/node/.openclaw/workspace-ws-binhnt-so-don-hang/agent-binhnt-so-don-hang",
    "identity": { "name": "Sổ Đơn Hàng" },
    "tools": { "profile": "minimal", "alsoAllow": ["read", "binhnt-so-don-hang"] },
    "skills": ["huong-dan-su-dung"]
  } } },
  "plugins": { "entries": { "binhnt-so-don-hang": { "enabled": true } } }
}
```

- `agents.entries.<id>` — KHÔNG dùng `agents.list` (dạng 6.x; 9.x từ chối cả cấu hình, gateway không lên).
- `tools.alsoAllow` có tên plugin của chính agent; không có `exec`.
- `skills` — allowlist: đúng các skill của agent. Không khai `skills.load.extraDirs`.
- Không có `env`, `channels`, `bindings`, `cron`, `plugins.allow`.
- Không có giá trị secret ở bất kỳ đâu.

## `install/`

- `install.sh`, `uninstall.sh`, `verify.sh`, `apply-overrides.mjs` (+ test), `eval.mjs` — script chung của
  nền tảng, chèn lúc đóng gói. Agent không mang bản riêng của các tệp này.
- `config.sh` — của riêng agent. Agent cá nhân dùng nó cho một việc: máy đã có `plugins.allow` không rỗng
  thì thêm plugin của agent vào (không có tên trong danh sách đó là plugin bị tắt im lặng). Lệnh lạ thì
  không làm gì.
- `install-wizard.yaml` — mô tả tối thiểu (tên, mô tả, bản OpenClaw thấp nhất); agent cá nhân không có gì
  để nhập lúc cài.

## Không bao giờ vào Bundle

- Nguồn plugin (`agent-<id>/plugins/`) — chỉ bản build `dist/<id>.zip`.
- Dữ liệu (`uc-data/<ws>/data.sqlite`), secret (`uc-data/<ws>/secrets.json`), lịch sử chat.
- Charter và ảnh chụp nguồn của CE Code (`builds/<ws>/source/`).

Người nhận agent bắt đầu với sổ trống và tự nhập khoá dịch vụ của họ.

## Phiên bản

- Mỗi lần `ce_package` ra một bản mới, ghi vào `builds/<ws>/versions.json` của CE Code: `version`,
  `parent` (bản được sửa từ đó), giờ, ghi chú.
- "Bản trước" = bản CHA trong sổ, không phải bản liền trước theo giờ. Quay lại thì đưa cả nguồn về bản đó
  (ảnh chụp nguồn ở `builds/<ws>/source/<bản>.zip`, không bao giờ được chia sẻ).
- Bản đang cài đọc từ `workspace-<ws>/bundle.json` trên máy.

## Cài

| Ai | Cách |
|---|---|
| Người tạo | `ce_install` — cài bản vừa đóng gói ngay trên máy họ |
| Người nhận | Terminal: `curl -fsSL …/install/oc-install.sh \| bash -s <link hoặc Drive file id>` |

`oc-install.sh` tải zip rồi, TRƯỚC khi giải nén, kiểm ba thứ trong `bundle.json` của zip: máy đã có agent
cùng tên mà uid khác ⇒ dừng (`--overwrite` để thay hẳn); `openclawMinVersion` mới hơn bản đang chạy ⇒ dừng
(`--skip-version-check` để cài vẫn); zip có plugin ⇒ in cảnh báo kèm số plugin. Qua kiểm thì giải nén đè vào
`~/.openclaw/` và chạy `install/install.sh`: cài plugin từ
`dist/`, đăng ký agent, gộp overlay, chạy `config.sh post-install`, kiểm lại. Trên 9.7 plugin mới được nạp
nóng, không cần khởi động lại gateway. Mở cuộc trò chuyện MỚI với agent để thấy bản mới.

Cài lại cùng `workspace.id` là cập nhật: dữ liệu trong `uc-data/<ws>/` còn nguyên.

## Gỡ

`bash ~/.openclaw/workspace-<ws>/install/uninstall.sh` — gỡ đăng ký agent và plugin; gateway khởi động lại
nên mọi agent khựng vài giây. Dữ liệu trong `uc-data/<ws>/` không bị xoá.
