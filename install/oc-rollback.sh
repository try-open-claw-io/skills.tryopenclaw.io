#!/usr/bin/env bash
# Lệnh cứu instance khi gateway không lên (hoặc chạy lỗi) vì plugin của một agent cá nhân — agent làm
# bằng ClawExperts Code, bundle.json có `workspace.author` (D-19 của ws-clawexperts-code).
# Chạy TRÊN instance: Terminal của Platform là docker exec thẳng vào container nên vẫn vào được khi
# gateway chết.
#
#   curl -fsSL <url>/oc-rollback.sh | bash -s -- --safe
#   curl -fsSL <url>/oc-rollback.sh | bash -s -- --ws ws-<author>-<slug>
#
#   --safe         tắt plugin của MỌI agent cá nhân (author khác "clawexperts"), rồi khởi động lại gateway.
#                  Agent chính chủ không bị đụng. Sau đó hỏi ClawExperts Code "kiểm lại tất cả agent".
#   --ws <ws>      cài lại bản liền trước của một agent mình làm (theo sổ phiên bản của ClawExperts Code
#                  trên máy này), rồi khởi động lại gateway.
#   --no-restart   không khởi động lại gateway.
#
# Không dùng jq (máy khách không có) và không đọc stdin (stdin là chính script khi chạy kiểu curl | bash).
# Sửa thẳng openclaw.json bằng node (luôn có trên instance) vì CLI openclaw có thể cũng nạp plugin hỏng.
set -euo pipefail

OC_HOME="${OC_HOME:-${OPENCLAW_STATE_DIR:-$HOME/.openclaw}}"
MODE=""
WS=""
RESTART=1

die()  { echo "✗ $*" >&2; exit 1; }
step() { echo "▸ $*"; }

while [ $# -gt 0 ]; do
  case "$1" in
    --safe)       MODE="safe"; shift ;;
    --ws)         MODE="ws"; WS="${2:-}"; [ -n "$WS" ] || die "--ws cần tên agent, vd ws-binhnt-so-don-hang"; shift 2 ;;
    --no-restart) RESTART=0; shift ;;
    -h|--help)    sed -n '2,19p' "$0" 2>/dev/null | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)            die "tham số lạ: $1 (dùng --safe hoặc --ws <ws>)" ;;
  esac
done
[ -n "$MODE" ] || die "thiếu chế độ. Dùng: oc-rollback.sh --safe | --ws ws-<author>-<slug> [--no-restart]"
command -v node >/dev/null 2>&1 || die "máy này không có node"
[ -f "$OC_HOME/openclaw.json" ] || die "không thấy $OC_HOME/openclaw.json (đặt OC_HOME nếu state nằm chỗ khác)"

restart_gateway() {
  [ "$RESTART" = 1 ] || { step "Bỏ qua khởi động lại gateway (--no-restart)"; return 0; }
  if command -v supervisorctl >/dev/null 2>&1; then
    step "Khởi động lại gateway (supervisorctl)"
    supervisorctl restart openclaw-gateway || die "supervisorctl không khởi động lại được openclaw-gateway"
  else
    echo "⚠ Không có supervisorctl: khởi động lại gateway bằng tay (vd restart container) để áp thay đổi."
  fi
}

if [ "$MODE" = "safe" ]; then
  step "Tìm agent cá nhân trong $OC_HOME"
  # Tắt trong openclaw.json mọi plugin của agent cá nhân, in mỗi plugin một dòng.
  OUT="$(OC_HOME="$OC_HOME" node -e '
    const fs = require("node:fs"), path = require("node:path");
    const home = process.env.OC_HOME;
    const cfgPath = path.join(home, "openclaw.json");
    const hits = [];
    for (const d of fs.readdirSync(home)) {
      if (!d.startsWith("workspace-ws-")) continue;
      let author;
      try { author = JSON.parse(fs.readFileSync(path.join(home, d, "bundle.json"), "utf8"))?.workspace?.author; } catch { continue; }
      if (typeof author !== "string" || !author || author === "clawexperts") continue;
      const dist = path.join(home, d, "dist");
      if (!fs.existsSync(dist)) continue;
      for (const f of fs.readdirSync(dist)) {
        const m = f.match(/^(.+)\.(zip|tgz|tar\.gz)$/);
        if (m) hits.push([d.slice("workspace-".length), m[1]]);
      }
    }
    if (hits.length) {
      const cfg = JSON.parse(fs.readFileSync(cfgPath, "utf8"));
      fs.copyFileSync(cfgPath, cfgPath + ".bak.oc-rollback");
      cfg.plugins ??= {};
      cfg.plugins.entries ??= {};
      for (const [, id] of hits) cfg.plugins.entries[id] = { ...(cfg.plugins.entries[id] ?? {}), enabled: false };
      fs.writeFileSync(cfgPath, JSON.stringify(cfg, null, 2) + "\n");
    }
    for (const [ws, id] of hits) console.log("  · tắt plugin " + id + " (agent " + ws + ")");
  ')"
  if [ -z "$OUT" ]; then
    echo "✓ Không có plugin nào của agent cá nhân — không tắt gì. Gateway không lên vì lý do khác: chạy 'openclaw doctor'."
    exit 0
  fi
  echo "$OUT"
  echo "  (bản sao cấu hình cũ: $OC_HOME/openclaw.json.bak.oc-rollback)"
  restart_gateway
  echo "✓ Xong. Khi gateway lên: hỏi ClawExperts Code \"kiểm lại tất cả agent\" để tìm plugin hỏng và sửa;"
  echo "  agent nhận từ người khác thì chờ tác giả cập nhật rồi chạy lại lệnh cài cũ."
  exit 0
fi

# --ws: bản liền trước = bản CHA của bản đang cài trong sổ phiên bản của ClawExperts Code (D-46).
step "Tìm bản trước của $WS"
ZIP="$(OC_HOME="$OC_HOME" WS="$WS" node -e '
  const fs = require("node:fs"), path = require("node:path");
  const { OC_HOME: home, WS: ws } = process.env;
  const builds = path.join(home, "uc-data", "ws-clawexperts-code", "builds", ws);
  const fail = (m) => { console.error(m); process.exit(2); };
  let log, installed;
  try { log = JSON.parse(fs.readFileSync(path.join(builds, "versions.json"), "utf8")); }
  catch { fail("máy này không có sổ phiên bản của " + ws + " (agent nhận về, hoặc không làm bằng ClawExperts Code) — dùng --safe"); }
  try { installed = JSON.parse(fs.readFileSync(path.join(home, "workspace-" + ws, "bundle.json"), "utf8"))?.package?.version; }
  catch { fail(ws + " chưa được cài trên máy này"); }
  const cur = (log.versions || []).find((v) => v.version === installed);
  if (!cur) fail("bản đang cài (" + installed + ") không có trong sổ phiên bản của " + ws);
  if (!cur.parent) fail("bản đang cài (" + installed + ") là bản đầu tiên — không có bản trước");
  const zip = path.join(builds, ws + "-" + cur.parent + ".zip");
  if (!fs.existsSync(zip)) fail("không còn zip của bản " + cur.parent);
  console.log(zip);
')" || die "không quay lại được"
step "Cài lại $(basename "$ZIP")"
if command -v unzip >/dev/null 2>&1; then
  unzip -oq "$ZIP" -d "$OC_HOME"
elif command -v python3 >/dev/null 2>&1; then
  python3 -m zipfile -e "$ZIP" "$OC_HOME"
else
  die "máy này không có unzip lẫn python3"
fi
( cd "$OC_HOME" && bash "workspace-$WS/install/install.sh" -v ) || die "install.sh của bản trước hỏng"
restart_gateway
echo "✓ Đã cài lại bản trước của $WS. Khi gateway lên: bảo ClawExperts Code \"cài lại bản $(basename "$ZIP" .zip | sed "s/^$WS-//") của $WS\""
echo "  để nguồn project của nó cũng về bản này."
