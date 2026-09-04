#!/usr/bin/env bash
# Cài / cập nhật MỘT use-case bundle lên instance OpenClaw.
# Chạy TRÊN instance (terminal của Platform, hoặc shell trong container) — 1 lệnh thay cho
# chuỗi gdown → unzip → install.sh → rm.
#
#   curl -fsSL <url>/oc-install.sh | bash -s <DRIVE_FILE_ID | URL> [--ws ws-<name>] [--no-install]
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
SRC=""

die()  { echo "✗ $*" >&2; exit 1; }
step() { echo "▸ $*"; }

while [ $# -gt 0 ]; do
  case "$1" in
    --ws)         WS="${2:-}"; [ -n "$WS" ] || die "--ws cần tên workspace"; shift 2 ;;
    --no-install) DO_INSTALL=0; shift ;;
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
elif command -v python3 >/dev/null 2>&1; then
  UNZIP() { python3 -m zipfile -e "$ZIP" "$1"; }
  LIST()  { python3 -c 'import sys,zipfile;print("\n".join(zipfile.ZipFile(sys.argv[1]).namelist()))' "$ZIP"; }
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
