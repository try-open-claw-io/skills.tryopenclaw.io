# Case C — Generate new plugin handler + route

Use this case when the user needs a new data destination that NO existing route in current manage.yaml can serve, and Case B does not apply.

This is the most invasive case. You will modify plugin source TypeScript, rebuild the plugin, and restart the gateway. Always run this case under the workspace lock (see `SKILL.md → Concurrency`). Always plan rollback per `safety-rollback.md` BEFORE starting.

## Preconditions you MUST verify first

- The workspace owns a plugin whose source you can write to. Find it: scan `$WS_DIR/agent-*/plugins/<plugin>/`. If the glob matches more than one `agent-*` folder OR more than one `plugins/<plugin>/`, ask the user which plugin should own the new feature. If none → escalate (workspace ships no plugin; nothing to extend).
- The plugin source has `src/handlers/` directory and `src/operation-routes.ts` (or equivalent registration entry — see step 4). If layout is unfamiliar → list the plugin's `src/` tree to the user and ask which file registers routes.
- The plugin already exposes the HTTP helpers the handler templates import (`sendJson`, `sendError`, `readJsonBody` from `./http.js`). Grep `<plugin>/src/handlers/` for these names. If missing → escalate (templates depend on them; generating an http helper from scratch is out of scope for v0).
- The plugin's `package.json` has a build script that compiles TS → `dist/`. Identify the script. Common names: `build:plugin`, `build:ship`, `build`. If unclear → ask user.
- `openclaw` CLI is on PATH inside the container (it always is).

If any precondition is unmet → reply to user, do NOT proceed.

## Step-by-step workflow

### 1. Plan the new route + data destination

Decide:
- `<feature>` — kebab-case slug for the feature (e.g. `bot-config`, `reply-templates`). Used in route path AND in file names.
- `<TARGET_FILE>` — relative path under `$WS_DIR` where the data lives (e.g. `BOT_CONFIG.json` or `RESPONSE_TEMPLATES.md`). MUST NOT contain `..`, MUST NOT be absolute, MUST NOT start with `.`.
- `<VIEW_TYPE>` — one of `textarea-edit-multi-section`, `list-view`, `data-import`, `leads-view`. For free-form text → `textarea-edit-multi-section`. For structured data → ask user about row schema first; structured data needs more handler logic than the templates provide.

Show user the plan in chat:
```
Tôi sẽ:
- Tạo route GET  /api/<ws>/<plugin>/<feature>/read  → đọc <TARGET_FILE>
- Tạo route POST /api/<ws>/<plugin>/<feature>/write → ghi <TARGET_FILE>
- Build lại plugin, restart gateway (~60-120s downtime nhẹ)
- Thêm tab "..." vào dashboard
File data sẽ là: <TARGET_FILE>
OK chạy?
```

WAIT for explicit "OK".

### 2. Acquire lock

Write `$WS_DIR/.edit-agent-dashboard.lock` containing your PID + ISO timestamp. If lock exists AND mtime newer than 5min → another agent is working, ask user to retry. If older than 5min → treat stale, overwrite.

### 3. Generate handler files

Templates use the **factory pattern**: each handler file exports a `make<Handler>(workspaceDir)` function that returns the actual request handler closure. This avoids module-level singletons and matches the SDK contract — `workspaceDir` is resolved once at registration time and injected into the handler factory.

Read `references/handler-templates/read-handler.ts.tmpl` + `write-handler.ts.tmpl`. Substitute placeholders:
- `{{FEATURE}}` → your `<feature>` (e.g. `bot-config`)
- `{{TARGET_FILE}}` → your `<TARGET_FILE>` (e.g. `BOT_CONFIG.json`)
- `{{HANDLER_NAME_READ}}` → camelCase `handle<Feature>Read` (e.g. `handleBotConfigRead`) — used inside the factory return
- `{{HANDLER_NAME_WRITE}}` → camelCase `handle<Feature>Write`

Write to:
- `<plugin>/src/handlers/<feature>-read.ts`
- `<plugin>/src/handlers/<feature>-write.ts`

The templates import `safeWorkspacePath` from `../workspace-files.js` by default. Adjust that import path if the plugin keeps path utilities elsewhere (grep for an existing `safeWorkspacePath` first; if found → reuse it, do NOT duplicate).

If `safeWorkspacePath` is missing from the plugin, Read `handler-templates/path-safety-helper.ts.tmpl` and add it to whichever module the handlers import from (most plugins use `src/workspace-files.ts`). The helper takes `(workspaceDir, relPath)` — pure function, no module-level binding required.

### 4. Register routes

Read `<plugin>/src/operation-routes.ts` (or the file where existing `api.registerHttpRoute({...})` calls live — grep for `registerHttpRoute` to confirm).

Read `references/handler-templates/registration-snippet.ts.tmpl`. The snippet has three parts to splice in:

1. **Imports** at the top of the file (alongside other handler imports):
   ```ts
   import { make<Feature>Read } from "./handlers/<feature>-read.js";
   import { make<Feature>Write } from "./handlers/<feature>-write.js";
   ```
   (Note `.js` extension — TS module resolution requires it after compile.)

2. **Resolve `workspaceDir` once** inside the registration function, BEFORE the new `registerHttpRoute` calls. The SDK canonical resolver is:
   ```ts
   const workspaceDir = api.runtime.agent.resolveAgentWorkspaceDir(api.config);
   ```
   **IMPORTANT — check first**: if a `workspaceDir` const already exists in the file (search for `resolveAgentWorkspaceDir|resolveWorkspaceRoot|workspaceDir =`), reuse it. If the plugin uses a different convention (e.g. a local `resolveWorkspaceRoot()` helper as `zalo-sales-commands` does), use that instead — do NOT introduce a parallel resolver.

3. **Register routes** by calling the factories with `workspaceDir`:
   ```ts
   api.registerHttpRoute({ path: `${BASE}/<feature>/read`, auth: "gateway", match: "exact", handler: make<Feature>Read(workspaceDir) });
   api.registerHttpRoute({ path: `${BASE}/<feature>/write`, auth: "gateway", match: "exact", handler: make<Feature>Write(workspaceDir) });
   ```
   `${BASE}` is the existing const in the file — read it (typically `/api/<ws>/<plugin>`) so your new route URL matches what you put in `manage.yaml` later.

### 5. Build the plugin

```sh
cd $WS_DIR/agent-*/plugins/<plugin>
<pm> run <build-script>
```

Where `<pm>` is `bun` / `pnpm` / `npm` (detect via lockfile) and `<build-script>` is what you identified in preconditions.

Verify:
- Exit code = 0
- `dist/` contents updated (e.g. `ls -lt dist/ | head -3` shows fresh mtime)

If either fails → IMMEDIATELY rollback per `safety-rollback.md`. Report the build error log (last ~20 lines) back to user.

### 6. Restart gateway

```sh
openclaw gateway restart
```

Wait 60 seconds (local) or up to 120 seconds (cloud). Plugins re-register lazily on first request. Probe the new route:

```sh
curl -sS -o /dev/null -w "%{http_code}" "http://localhost:<gateway-port>/api/<ws>/<plugin>/<feature>/read" \
  -H "Authorization: Bearer $OPENCLAW_GATEWAY_TOKEN"
```

Expected: 200 (or 4xx but NOT 404). A 404 means route did not register → rollback.

If you don't know the gateway port → try `openclaw status --json` to find it, or fall back to checking `~/.openclaw/openclaw.json::gateway.port`.

### 7. Update manage.yaml

Now (and ONLY now) add the new view entry to `manage.yaml`. For a `textarea-edit-multi-section` backed by your new routes:

```yaml
- id: <feature>
  label: "<Vietnamese label>"
  help: "<Vietnamese help>"
  icon: settings
  entry_condition: "install_status == 'verified'"
  views:
    - id: <feature>-edit
      type: textarea-edit-multi-section
      label: "<Vietnamese view label>"
      data_source:
        plugin_route: "/api/<ws>/<plugin>/<feature>/read"
      save_route: "/api/<ws>/<plugin>/<feature>/write"
      sections:
        - id: <feature>-main
          label: "Nội dung"
          section: "<Vietnamese section header — will become a '## <header>' block in the target file>"
```

The `section:` value MUST be a non-empty string — the renderer parses the target file by `## <header>` markers, and empty section means undefined behavior. For a single-section view, pick a descriptive header (e.g. `"Cấu hình bot reply"`) — it appears as `## Cấu hình bot reply` in the saved file. For multi-section, add multiple section entries each with a unique header. For other view types, see `view-types.yaml` for the required shape.

Backup `manage.yaml.bak` before write. Write the file.

### 8. Release lock + tell user

Delete `$WS_DIR/.edit-agent-dashboard.lock`. Reply to user:

> Đã thêm tab "...". Route mới: `GET /api/<ws>/<plugin>/<feature>/read` + `POST /.../write`. File data: `<TARGET_FILE>` (sẽ tự tạo khi bạn nhập + lưu lần đầu). Refresh `/use-cases/:id/operate` để thấy tab mới.

## Common pitfalls

- **Forgetting `.js` extension in import** → build fails at runtime with module-not-found.
- **Path traversal in `<TARGET_FILE>`** → use `safeWorkspacePath()` always; check input before storing.
- **Adding manage.yaml view BEFORE build/restart succeeds** → dangling reference, FE errors on load.
- **Skipping the lock** → race conditions with parallel agents corrupt manage.yaml.
- **Forgetting to update imports in operation-routes.ts** → build error.
- **Bundle re-install resets everything** — End-User should be warned: customizations are ephemeral until they explicitly save/export the changes via Expert flow.

## Beyond textarea-edit (advanced)

For `list-view` / `data-import` / `leads-view` with NEW data destinations, the templates in `handler-templates/` are NOT sufficient — those view types require typed row schemas, CSV parsing, sheet integration, etc.

If user requests one of these → DO NOT attempt to generate from scratch. Reply:

> Tab dạng list/import/leads cần plugin logic phức tạp hơn (parse, schema, integration). Mình tạo route đọc-ghi file đơn giản được; muốn xử lý dạng table thì cần Expert thêm route chuyên biệt vào plugin.

Then offer Case C with `textarea-edit-multi-section` storing the data as JSON-as-text if that's acceptable.
