# Case B — Add view/phase reusing an existing route

Use this case when the user wants a new tab/view but the data can be served by a route ALREADY wired in the current manage.yaml. No plugin code change, no rebuild.

This case is preferred over Case C whenever possible. Always check Case B first.

## When Case B applies

Scan current manage.yaml. List every value of:
- `data_source.plugin_route`
- `save_route`
- `upload_route`
- `submit_route`
- `url_route`

For each route, the SAME route can usually back another view if the new view uses the same `type` and the data destination semantics match.

The most common Case B is **new section in a multi-section textarea**. Example: `ws-zalo-sale-force` ships a `textarea-edit-multi-section` view backed by `/kb/read` + `/kb/write` which both read/write the entire `KNOWLEDGE_BASE.md` file with section parsing. To add ANY new free-form-text tab, add a new `textarea-edit-multi-section` view reusing those routes, with a fresh `sections[]` entry. The new section becomes a new `## <header>` block in KB.md.

Case B can also apply for:
- Adding a second `list-view` showing a different column subset of the same plugin's table data
- Adding a second `data-import` button with the same `upload_route` but different `max_rows` cap

## When Case B does NOT apply

- The user wants data stored in a DIFFERENT file (not the one routes already touch)
- The user wants a different `view type` than any currently in manage.yaml (e.g. only KB editor exists, user wants a list-view)
- The user wants different data semantics (e.g. existing `/kb/write` overwrites; user wants append-only)

→ Fall through to Case C.

## Workflow

1. Read manage.yaml + `references/view-types.yaml`.
2. Identify route-reuse opportunity.
3. Compose the new View entry (or new Phase wrapping it). For section parameterization:
   - Pick a fresh `id` (kebab-case, unique in the view)
   - Pick a Vietnamese `label`
   - Pick a `section` header string that does NOT already exist in the target file
4. Show user the diff including a 1-line "Tab mới này sẽ ghi vào file X (cùng file với tab Y)." disclosure so the user understands data location.
5. On "OK":
   - Backup manage.yaml.bak
   - Write new manage.yaml
   - Tell user: "Đã thêm tab. Section mới sẽ tự tạo trong `<file>` khi bạn nhập + lưu lần đầu. Refresh dashboard."

## Example

User: "Thêm tab cấu hình bot — phần giờ giảm giá và mức độ thân mật."

Existing manage.yaml has:
```yaml
- id: kb-all
  type: textarea-edit-multi-section
  data_source:
    plugin_route: "/api/ws-zalo-sale-force/zalo-sales-commands/kb/read"
  save_route: "/api/ws-zalo-sale-force/zalo-sales-commands/kb/write"
  sections:
    - id: kb-faq
      label: "FAQ"
      section: "FAQ"
    - id: kb-policy
      label: "Chính sách (đổi trả, vận chuyển, bảo hành)"
      section: "Chính sách (đổi trả, vận chuyển, bảo hành)"
    - id: kb-voice
      label: "Brand voice"
      section: "Brand voice"
```

Agent diff (adds a new phase reusing the same routes):
```diff
   - id: knowledge
     label: "Bước 2 — Cấu hình Agent"
     ...
+  - id: bot-config
+    label: "Cấu hình bot reply"
+    help: "Giờ giảm giá + mức độ thân mật."
+    icon: settings
+    entry_condition: "install_status == 'verified'"
+    views:
+      - id: bot-config-edit
+        type: textarea-edit-multi-section
+        label: "Cấu hình bot"
+        data_source:
+          plugin_route: "/api/ws-zalo-sale-force/zalo-sales-commands/kb/read"
+        save_route: "/api/ws-zalo-sale-force/zalo-sales-commands/kb/write"
+        sections:
+          - id: bot-discount-hours
+            label: "Giờ giảm giá"
+            section: "Giờ giảm giá"
+          - id: bot-tone
+            label: "Mức độ thân mật"
+            section: "Mức độ thân mật"
```

Disclosure to user: "Tab mới này sẽ ghi vào `KNOWLEDGE_BASE.md` cùng file với tab 'Kiến thức agent'. Cùng file, khác section."

## When NOT to use Case B even if technically possible

- If the user explicitly asks for "lưu vào file riêng" / "file mới" → user wants Case C. Don't force-fit Case B.
- If reusing the route would mix unrelated content in one file (e.g. mixing bot config with FAQ in KB) and the user clearly meant separation → go Case C instead.
