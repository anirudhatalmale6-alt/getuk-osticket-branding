#!/usr/bin/env bash
#
# GetUK osTicket branding - apply to an existing osTicket 1.18.x install.
#
#   ./apply-branding.sh /path/to/osticket/upload
#
# Idempotent: safe to re-run, and safe to run again after an osTicket
# upgrade (an upgrade overwrites the two header templates, which is the
# only thing this script edits).
#
set -euo pipefail

TARGET="${1:-}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

if [[ -z "$TARGET" ]]; then
    echo "usage: $0 /path/to/osticket/upload" >&2
    exit 1
fi

CLIENT_HEADER="$TARGET/include/client/header.inc.php"
STAFF_HEADER="$TARGET/include/staff/header.inc.php"

for f in "$CLIENT_HEADER" "$STAFF_HEADER"; do
    [[ -f "$f" ]] || { echo "not an osTicket upload dir - missing $f" >&2; exit 1; }
done

echo "==> target: $TARGET"

# ---------------------------------------------------------------- css
install -D -m 0644 "$HERE/css/getuk.css"     "$TARGET/assets/default/css/getuk.css"
install -D -m 0644 "$HERE/css/getuk-scp.css" "$TARGET/scp/css/getuk-scp.css"
echo "    stylesheets copied"

# ------------------------------------------------------- header <link>
# Inserted immediately before the favicon block so it loads last and wins.

add_link() {
    local file="$1" marker="$2" line="$3"
    if grep -q "$marker" "$file"; then
        echo "    already linked: $(basename "$file")"
        return
    fi
    cp -a "$file" "$file.bak.$STAMP"
    # awk rather than sed: the line contains slashes, quotes and PHP tags
    awk -v ins="$line" '
        !done && /<!-- Favicons -->/ { print ins; done=1 }
        { print }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    chmod --reference="$file.bak.$STAMP" "$file"
    echo "    linked: $(basename "$file")  (backup: $(basename "$file").bak.$STAMP)"
}

add_link "$CLIENT_HEADER" "css/getuk.css" \
'    <link type="text/css" rel="stylesheet" href="<?php echo ASSETS_PATH; ?>css/getuk.css?v5"/>'

add_link "$STAFF_HEADER" "css/getuk-scp.css" \
'    <link type="text/css" rel="stylesheet" href="<?php echo ROOT_PATH ?>scp/css/getuk-scp.css?v2"/>'

cat <<'NEXT'

==> done.

Two things are NOT done by this script, because they belong in the admin UI
where they survive upgrades cleanly:

  1. Logo
     Admin Panel -> Settings -> Pages -> upload content/getuk-logo.png,
     then tick it for BOTH "Landing Page Logo" and "Staff Panel Logo".

  2. Landing page copy
     Admin Panel -> Manage -> Pages -> Landing, paste content/landing-page.html
     (use the editor's source view). Check the phone number is current.

After any osTicket upgrade, re-run this script - the upgrade replaces the two
header templates and drops the <link> lines. The stylesheets themselves are
left alone by upgrades.
NEXT
