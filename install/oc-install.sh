#!/usr/bin/env bash
# Cài / cập nhật MỘT use-case bundle lên instance OpenClaw.
# Chạy TRÊN instance (terminal của Platform, hoặc shell trong container) — 1 lệnh thay cho
# chuỗi gdown → unzip → install.sh → rm.
#
#   curl -fsSL <url>/oc-install.sh | bash -s <DRIVE_FILE_ID | URL> [--ws ws-<name>] [--no-install] [--overwrite]
#
#   --overwrite           máy đã có một agent KHÁC cùng tên ws (workspace.uid khác) — vẫn thay hẳn bằng bundle này
#   --skip-version-check  cài dù bundle ghi cần OpenClaw mới hơn bản máy đang chạy
#
# VÌ SAO không dùng gdown: bundle ~1MB nằm dưới ngưỡng virus-scan của Drive, nên
# drive.usercontent.google.com trả file trực tiếp cho curl — không cần cài python/gdown
# lên máy khách chỉ để tải một file.
#
# Tên workspace KHÔNG cần gõ: zip có đúng một thư mục gốc `workspace-ws-<name>/`, script đọc ra.
# Ép bằng --ws chỉ khi zip lạ (nhiều thư mục gốc).
set -euo pipefail

OC_HOME="${OC_HOME:-$HOME/.openclaw}"
WS=""
DO_INSTALL=1
OVERWRITE=0
SKIP_VERSION=0
SRC=""

die()  { echo "✗ $*" >&2; exit 1; }
step() { echo "▸ $*"; }

while [ $# -gt 0 ]; do
  case "$1" in
    --ws)         WS="${2:-}"; [ -n "$WS" ] || die "--ws cần tên workspace"; shift 2 ;;
    --no-install) DO_INSTALL=0; shift ;;
    --overwrite)  OVERWRITE=1; shift ;;
    --skip-version-check) SKIP_VERSION=1; shift ;;
    -h|--help)
      sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    -*)           die "tham số lạ: $1" ;;
    *)            [ -z "$SRC" ] || die "chỉ nhận MỘT nguồn (file id hoặc URL)"; SRC="$1"; shift ;;
  esac
done
[ -n "$SRC" ] || die "thiếu nguồn. Dùng: oc-install.sh <DRIVE_FILE_ID | URL> [--ws ws-<name>] [--no-install]"

# Drive file id (không phải URL) → dựng URL tải thẳng.
case "$SRC" in
  http://*|https://*) URL="$SRC" ;;
  *)                  URL="https://drive.usercontent.google.com/download?id=${SRC}&export=download" ;;
esac

ZIP="$(mktemp -t oc-bundle-XXXXXX.zip)"
trap 'rm -f "$ZIP"' EXIT

step "Tải bundle"
if   command -v curl >/dev/null 2>&1; then
  curl -fL --retry 3 --retry-delay 2 --progress-bar -o "$ZIP" "$URL" \
    || die "không tải được. Kiểm tra: link còn sống? file đã để 'ai có link cũng xem được'? máy có ra được internet?"
elif command -v wget >/dev/null 2>&1; then
  wget -q -O "$ZIP" "$URL" || die "không tải được (wget). Kiểm tra link + quyền chia sẻ + mạng."
else
  die "máy này không có curl lẫn wget"
fi

# Link Drive không được chia sẻ công khai trả về TRANG HTML đăng nhập với mã 200 — bắt ở đây,
# nếu không unzip sẽ báo "End-of-central-directory signature not found" và không ai hiểu vì sao.
[ -s "$ZIP" ] || die "file tải về rỗng"
[ "$(head -c 2 "$ZIP")" = "PK" ] || die "tải về không phải file zip (Drive thường trả trang đăng nhập khi link CHƯA để 'ai có link cũng xem được')"
step "Đã tải $(wc -c <"$ZIP" | tr -d ' ') byte"

if command -v unzip >/dev/null 2>&1; then
  UNZIP() { unzip -oq "$ZIP" -d "$1"; }
  LIST()  { unzip -Z1 "$ZIP"; }
  CAT()   { unzip -p "$ZIP" "$1"; }
elif command -v python3 >/dev/null 2>&1; then
  UNZIP() { python3 -m zipfile -e "$ZIP" "$1"; }
  LIST()  { python3 -c 'import sys,zipfile;print("\n".join(zipfile.ZipFile(sys.argv[1]).namelist()))' "$ZIP"; }
  CAT()   { python3 -c 'import sys,zipfile;sys.stdout.write(zipfile.ZipFile(sys.argv[1]).read(sys.argv[2]).decode())' "$ZIP" "$1"; }
else
  die "máy này không có unzip lẫn python3"
fi

if [ -z "$WS" ]; then
  ROOTS="$(LIST | sed -E 's#/.*##' | sort -u | grep '^workspace-' || true)"
  [ -n "$ROOTS" ] || die "zip không chứa thư mục workspace-<ws>/ nào"
  [ "$(printf '%s\n' "$ROOTS" | wc -l | tr -d ' ')" = "1" ] || die "zip có nhiều workspace — chỉ rõ bằng --ws: $(printf '%s ' $ROOTS)"
  WS="${ROOTS#workspace-}"
fi
step "Workspace: $WS"

WS_DIR="$OC_HOME/workspace-$WS"

# Đọc một trường chuỗi của JSON trên stdin ("a.b"); thiếu hay hỏng thì in rỗng. Không dùng jq: máy khách không có.
jget() {
  if command -v node >/dev/null 2>&1; then
    node -e 'let s="";process.stdin.on("data",(d)=>(s+=d)).on("end",()=>{try{let v=JSON.parse(s);for(const k of process.argv[1].split("."))v=v?.[k];if(typeof v==="string")process.stdout.write(v)}catch{}})' "$1"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c 'import sys,json
try:
  v=json.load(sys.stdin)
  for k in sys.argv[1].split("."): v=v.get(k) if isinstance(v,dict) else None
  sys.stdout.write(v if isinstance(v,str) else "")
except Exception: pass' "$1"
  fi
}
NEW_BUNDLE="$(CAT "workspace-$WS/bundle.json" 2>/dev/null || true)"

# Hai tác giả có thể trùng author name + slug: cùng tên ws mà khác uid là agent KHÁC, đè lên là mất agent đang có.
# Thiếu uid ở một bên (bundle cũ, hay ws chính chủ) thì không đủ căn cứ — cài như trước giờ.
NEW_UID="$(printf '%s' "$NEW_BUNDLE" | jget workspace.uid)"
OLD_UID="$([ -f "$WS_DIR/bundle.json" ] && jget workspace.uid <"$WS_DIR/bundle.json" || true)"
if [ -n "$NEW_UID" ] && [ -n "$OLD_UID" ] && [ "$NEW_UID" != "$OLD_UID" ] && [ "$OVERWRITE" = "0" ]; then
  die "máy đã có $WS nhưng đó là một agent KHÁC trùng tên (uid $OLD_UID, bundle này $NEW_UID). Không đè.
  Muốn thay hẳn agent đang có bằng bundle này: chạy lại đúng lệnh vừa rồi, thêm --overwrite ở cuối."
fi

# Plugin dựng cho OpenClaw mới hơn có thể nạp lỗi trên bản cũ, và một plugin nạp lỗi chặn cài mọi plugin khác.
# So từng đoạn số (2026.10.1 mới hơn 2026.9.7) — so chuỗi thì sai.
ver_lt() { awk -v a="$1" -v b="$2" 'BEGIN{n=split(a,x,/[.-]/);m=split(b,y,/[.-]/);for(i=1;i<=(n>m?n:m);i++){if(x[i]+0<y[i]+0)exit 0;if(x[i]+0>y[i]+0)exit 1};exit 1}'; }
MIN_VER="$(printf '%s' "$NEW_BUNDLE" | jget workspace.openclawMinVersion)"
if [ -n "$MIN_VER" ]; then
  RUNNING="$(openclaw --version 2>/dev/null | grep -oE '[0-9]{4}\.[0-9]+\.[0-9]+' | head -1 || true)"
  if [ -z "$RUNNING" ]; then
    step "Không đọc được phiên bản OpenClaw đang chạy — bỏ qua kiểm bản tối thiểu ($MIN_VER)"
  elif ver_lt "$RUNNING" "$MIN_VER" && [ "$SKIP_VERSION" = "0" ]; then
    die "bundle này cần OpenClaw $MIN_VER trở lên, máy đang chạy $RUNNING. Cài vào có thể làm plugin nạp lỗi.
  Nâng OpenClaw trước; chắc chắn vẫn muốn cài thì chạy lại đúng lệnh vừa rồi, thêm --skip-version-check ở cuối."
  fi
fi
# Plugin chạy trong tiến trình gateway nên đọc được mọi env và secret của instance (D-24 ws-clawexperts-code).
# Chỉ báo, không chặn: người cài đã nhận "tự chịu trách nhiệm", nhưng phải biết điều đó ngay lúc cài.
PLUGINS="$(LIST | grep -cE "^workspace-$WS/dist/[^/]+\.(zip|tar\.gz|tgz)$" || true)"
if [ "${PLUGINS:-0}" -gt 0 ]; then
  echo "⚠ Bundle này có $PLUGINS plugin, chạy với toàn quyền instance và đọc được mọi secret. Chỉ cài Bundle từ người bạn tin."
fi

mkdir -p "$OC_HOME"
step "Giải nén → $WS_DIR"
UNZIP "$OC_HOME"

INSTALLER="$WS_DIR/install/install.sh"
[ -f "$INSTALLER" ] || die "không thấy $INSTALLER sau khi giải nén"

if [ "$DO_INSTALL" = "0" ]; then
  echo "✓ Đã giải nén, bỏ qua install (--no-install). Chạy tay: bash $INSTALLER -v"
  exit 0
fi

step "Chạy install.sh"
bash "$INSTALLER" -v
echo "✓ Xong: $WS"
