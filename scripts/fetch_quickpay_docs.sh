#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${HEEPAY_DOCS_BASE_URL:-https://open.heepay.com}"
SSH_HOST="${HEEPAY_DOCS_SSH_HOST:-}"
OUT_DIR="${HEEPAY_DOCS_OUT_DIR:-tmp/heepay-quickpay-docs}"
PROD_ID="${HEEPAY_QUICKPAY_PROD_ID:-10002}"

mkdir -p "$OUT_DIR"

fetch() {
  local url="$1"
  if [[ -n "$SSH_HOST" ]]; then
    ssh "$SSH_HOST" "curl -fsSL '$url'"
  else
    curl -fsSL "$url"
  fi
}

menu_url="${BASE_URL}/Fapi/Doc/ProdDoc.aspx?doType=getDocMenu&prodId=${PROD_ID}"
echo "Fetching menu: $menu_url" >&2
fetch "$menu_url" > "${OUT_DIR}/quickpay-menu.json"

menu_ids=(
  "1501:0"
  "1502:0"
  "1504:0"
  "1505:0"
  "1021017006:1"
  "1021017011:1"
  "1021017010:1"
  "1021017007:1"
  "1021017008:1"
  "1021017005:1"
  "1021017009:1"
)

for pair in "${menu_ids[@]}"; do
  menu_id="${pair%%:*}"
  menu_type="${pair##*:}"
  url="${BASE_URL}/Fapi/Doc/ProdDoc.aspx?doType=getDocContent&menuId=${menu_id}&menuType=${menu_type}&prodId=${PROD_ID}"
  echo "Fetching content: menuId=${menu_id} menuType=${menu_type}" >&2
  fetch "$url" > "${OUT_DIR}/quickpay-${menu_id}.json" || {
    echo "WARN: failed to fetch menuId=${menu_id}" >&2
  }
done

cat <<MSG
Fetched Heepay Quick Pay docs into: ${OUT_DIR}

Review and sanitize before committing. Do not commit merchant secrets, JWTs,
card numbers, ID-card numbers, SMS codes, or raw sensitive callback payloads.
MSG

