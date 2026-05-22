# Case A — Rename / layout / reorder / remove

Use this case when the user wants to change only text or structure of the existing dashboard, without adding new views.

## Allowed operations

| Operation | Target | Constraint |
|---|---|---|
| Rename phase label/help/icon | `/operation_phases/{i}/label` etc. | text ≤80 chars |
| Rename view label | `/operation_phases/{i}/views/{j}/label` | text ≤80 chars |
| Change layout | `/layout` | `tabs` or `accordion` only |
| Remove a phase | `/operation_phases/{i}` (delete) | min 0 phases (empty dashboard OK) |
| Remove a view | `/operation_phases/{i}/views/{j}` (delete) | if last view in phase → ask user if they want to remove the phase too |
| Reorder phases | move within `/operation_phases/` | preserve all phase ids |
| Reorder views inside a phase | move within `/operation_phases/{i}/views/` | preserve all view ids |

Path values OUTSIDE the table above → reject. If user asks to change e.g. `plugin_route`, `save_route`, `columns`, `row_actions`, `type` of an existing view → escalate (Case C or escalate to Platform Owner / Expert).

## Workflow

1. Read `$WS_DIR/install/manage.yaml`.
2. Match the user's intent against the allowed-operations table. If the request falls outside → reply "Yêu cầu này nằm ngoài phạm vi rename/layout. Mình sẽ thử như Case B/C nếu cần thêm tab mới — nói rõ giúp mình."
3. Compute the new YAML (in your head, then write it as text in your reply).
4. Show the user a unified diff (`---` / `+++` format is fine) and ask "OK đổi?".
5. On "OK":
   - Copy current `manage.yaml` to `manage.yaml.bak` (overwrite previous backup).
   - Write the new YAML.
   - Tell user: "Đã đổi. Refresh `/use-cases/:id/operate` để thấy thay đổi."

## Edge cases

- **User wants to rename `entry_condition`** — reject. `install_status == 'verified'` is the only valid value.
- **User wants to rename `type` of a view** — reject. Changing type = different renderer = different data shape. Treat as "remove old view + add new view of new type" (Case B or C).
- **User wants to remove the LAST phase** — ask: "Bỏ phase cuối sẽ làm dashboard trống. Vẫn muốn xoá?"
- **User wants to change `setup_steps`** — reject. setup_steps is in install-wizard.yaml, not manage.yaml. Out of scope of this skill.

## Example diff

User: "Đổi label 'Bước 1 — Quản lý sản phẩm' thành 'Quản lý hàng hoá'."

Agent diff:
```diff
 operation_phases:
   - id: catalog
-    label: "Bước 1 — Quản lý sản phẩm"
+    label: "Quản lý hàng hoá"
     help: "Nhập danh sách sản phẩm mới hoặc kiểm tra danh sách hiện có."
     icon: package
     entry_condition: "install_status == 'verified'"
```
