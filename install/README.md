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

Nguồn gốc: `toc-use-cases/scripts/deploy/oc-install.sh` — sửa ở đó rồi copy sang đây.
