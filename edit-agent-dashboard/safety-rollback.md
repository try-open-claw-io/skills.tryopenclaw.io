# Safety & rollback

Read this BEFORE starting Case C, and execute it on ANY failure during Case C.

## Path safety (when generating handlers)

The templates in `handler-templates/` already call `safeWorkspacePath(workspaceDir, input)` before any `fs` operation. Do NOT remove that call. The helper is a pure function taking `(workspaceDir, relPath)` — `workspaceDir` flows in from the factory closure (resolved at registration time via the SDK API). The helper enforces:

1. Reject if input contains `..` segment (anywhere).
2. Reject if input is absolute (starts with `/` on Unix, `<letter>:` on Windows).
3. Reject if input starts with `.` (no dotfiles).
4. Reject if input contains backslash `\` (Windows-style separator).
5. Resolve final absolute path; check it STARTS with the workspaceDir prefix (string `startsWith`, not just `resolve`).

If any check fails → return 400 `invalid_path`.

If `safeWorkspacePath` is missing from the plugin's `workspace-files.ts`, add it from `handler-templates/path-safety-helper.ts.tmpl` BEFORE generating handlers that depend on it.

## Build verification

After running the build script, the build is OK iff:
- Exit code is exactly 0
- `dist/` mtime changed (i.e., new artifacts written)
- The expected entry file (`dist/index.js` typically) exists and has non-zero size

If any check fails → treat as build failure and rollback.

## Rollback algorithm

When Case C fails at any step, execute steps below IN REVERSE ORDER from the last successful step. Stop at the first one that doesn't apply (if you never got there).

### If step 7 (manage.yaml update) was reached
- Restore `manage.yaml` from `manage.yaml.bak` (= cp .bak → original).
- Continue to next item.

### If step 6 (restart) was reached
- Gateway is now running broken plugin. Need to revert source + rebuild + restart again.
- Continue.

### If step 5 (build) was reached
- Source files are partially modified. Continue.

### If step 4 (register-routes edit) was reached
- Read `<plugin>/src/operation-routes.ts`.
- Locate the 2 `api.registerHttpRoute` calls and the 2 `import` lines you added.
- Edit-remove them.
- Restore the file to pre-edit state (if a `.bak` was kept of operation-routes.ts, use that — see "Defensive backups" below).

### If step 3 (handler write) was reached
- Delete `<plugin>/src/handlers/<feature>-read.ts`
- Delete `<plugin>/src/handlers/<feature>-write.ts`
- If you added `safeWorkspacePath` to workspace-files.ts as part of this run → DO NOT remove it (other code paths may already reference it). Leaving the helper is safe; removing it is risky.

### Re-build + re-restart after rollback
After reverting handlers + registration:
- Run the build script again.
- If build succeeds → restart gateway.
- If build STILL fails → the plugin was broken before your edits OR rollback was incomplete. Show user the build log, ask for guidance, do not auto-retry.

### Lock release
ALWAYS delete `$WS_DIR/.edit-agent-dashboard.lock` at the end of rollback, even if rollback partially failed.

## Defensive backups

BEFORE step 4 (registration edit), save a copy:
```sh
cp <plugin>/src/operation-routes.ts <plugin>/src/operation-routes.ts.bak
```

After successful workflow → delete the .bak. After failure rollback → restore from .bak and then delete.

## Report format on failure

When reporting failure to user, include:

1. Which step failed (1-7)
2. The first ~20 lines of build output / error message
3. Whether rollback completed cleanly ("Đã revert sạch" vs "Cần Platform Owner can thiệp")
4. Suggested next action

Example:
```
❌ Build fail ở step 5.
Build output (tail):
  src/handlers/bot-config-write.ts:14:23 - error TS2304: Cannot find name 'unsafe'.

Đã revert sạch:
  - Xoá: src/handlers/bot-config-{read,write}.ts
  - Restore: src/operation-routes.ts (từ .bak)
  - Plugin rebuild OK, gateway restart OK
  - manage.yaml giữ nguyên (chưa đụng)

Nguyên nhân khả năng cao: template có placeholder không substitute đúng. Báo Platform Owner để check template.
```

## What rollback does NOT cover

- Half-written `<TARGET_FILE>` if the plugin code partially wrote before failing. Agent should NOT pre-create the target file — let the new write handler create it on first save.
- Corrupted `manage.yaml.bak` (you overwrote it twice in one workflow). Avoid by writing .bak only once per workflow at the very start.
- Gateway in zombie state if `openclaw gateway restart` itself fails. In that case, run `openclaw gateway start` manually and check `openclaw status`.
