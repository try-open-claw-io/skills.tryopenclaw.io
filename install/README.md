# install/ — script cài đặt chạy trên instance khách

Thư mục này KHÔNG phải Platform Skill playbook: root `llms.txt` không liệt kê nó,
không `SKILL.md` router nào fetch nó, và nó không theo quy ước `<skill>/llms.txt`.
Nó ở đây chỉ để có một **URL raw công khai, ổn định** mà máy khách `curl` được.

## oc-install.sh — cài/cập nhật một use-case bundle

Chạy trên terminal của instance (Platform → Terminal, hoặc shell trong container):

```bash
curl -fsSL https://raw.githubusercontent.com/try-open-claw-io/skills.tryopenclaw.io/main/install/oc-install.sh \
  | bash -s <GOOGLE_DRIVE_FILE_ID>
```

Khi DNS `skills.tryopenclaw.io` lên, URL rút gọn thành (cùng path):

```bash
curl -fsSL https://skills.tryopenclaw.io/install/oc-install.sh | bash -s <GOOGLE_DRIVE_FILE_ID>
```

Tên workspace không cần gõ — script đọc thư mục gốc `workspace-ws-<name>/` trong zip.
Tuỳ chọn: `--ws ws-<name>` (ép tên), `--no-install` (chỉ tải + giải nén).
Nguồn cũng nhận URL trực tiếp thay cho Drive file id.

Trước khi giải nén, script đọc `bundle.json` trong zip (bằng node hoặc python3, không cần `jq`):

- **Agent khác trùng tên** — máy đã có `workspace-<ws>/` và cả hai bên có `workspace.uid` nhưng khác nhau
  ⇒ dừng, không đè. Muốn thay hẳn: thêm `--overwrite`. Thiếu uid ở một bên (bundle cũ) thì cài như trước.
- **Bản OpenClaw** — `workspace.openclawMinVersion` mới hơn `openclaw --version` ⇒ dừng (plugin dựng cho bản
  mới có thể nạp lỗi). Chắc chắn vẫn cài: thêm `--skip-version-check`. Không đọc được bản đang chạy thì bỏ qua kiểm.
- **Plugin** — zip có plugin trong `dist/` ⇒ in một dòng cảnh báo kèm số plugin (plugin đọc được mọi secret
  của instance). Không chặn.

Nguồn gốc: `toc-use-cases/scripts/deploy/oc-install.sh` — sửa ở đó rồi copy sang đây.

## oc-rollback.sh — cứu instance khi gateway không lên vì plugin của agent cá nhân

Agent cá nhân = agent làm bằng ClawExperts Code (`bundle.json` có `workspace.author`). Terminal của
Platform là `docker exec` vào container nên vẫn chạy được khi gateway chết:

```bash
# tắt plugin của MỌI agent cá nhân rồi khởi động lại gateway (agent chính chủ không bị đụng)
curl -fsSL https://raw.githubusercontent.com/try-open-claw-io/skills.tryopenclaw.io/main/install/oc-rollback.sh \
  | bash -s -- --safe

# cài lại bản liền trước của MỘT agent mình làm (theo sổ phiên bản của ClawExperts Code trên máy này)
curl -fsSL https://raw.githubusercontent.com/try-open-claw-io/skills.tryopenclaw.io/main/install/oc-rollback.sh \
  | bash -s -- --ws ws-<author>-<slug>
```

Gateway lên lại rồi thì hỏi ClawExperts Code "kiểm lại tất cả agent": nó nạp thử từng plugin đang tắt
trong một tiến trình riêng và chỉ ra plugin làm sập. Thêm `--no-restart` để không khởi động lại gateway.
Không dùng `jq`, không đọc stdin; sửa thẳng `openclaw.json` bằng node (bản sao cũ: `openclaw.json.bak.oc-rollback`).

Nguồn gốc: `toc-use-cases/scripts/deploy/oc-rollback.sh` (+ test `oc-rollback.test.mjs`) — sửa ở đó rồi copy sang đây.

