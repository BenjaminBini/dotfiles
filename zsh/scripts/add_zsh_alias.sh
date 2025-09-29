#!/bin/bash
set -euo pipefail

# Usage: add_zsh_alias.sh <alias> <command> <section> [description]

if [[ $# -lt 3 ]]; then
  echo "Usage: add_zsh_alias <alias> <command> <section> [description]" >&2
  exit 1
fi

ALIAS_NAME="$1"
ALIAS_CMD="$2"
SECTION="$3"
DESCRIPTION="${4-}"

ALIAS_LINE="alias $ALIAS_NAME=\"$ALIAS_CMD\""
if [[ -n "$DESCRIPTION" ]]; then
  ALIAS_LINE+=" # $DESCRIPTION"
fi

ALIAS_FILE="$HOME/.zsh_aliases"
TMP_FILE="$(mktemp)"

# Read all section headers into SECTIONS array (POSIX compatible)
SECTIONS=()
while IFS= read -r line; do
  section_name="${line#\# }"
  SECTIONS+=("$section_name")
done < <(grep -E '^# ' "$ALIAS_FILE")

# Check if section exists
SECTION_EXISTS=false
for s in "${SECTIONS[@]}"; do
  if [[ "$s" == "$SECTION" ]]; then
    SECTION_EXISTS=true
    break
  fi
done

# If section exists, process and insert alias
if $SECTION_EXISTS; then
  awk -v section="$SECTION" -v alias_line="$ALIAS_LINE" -v alias_name="$ALIAS_NAME" '
    BEGIN { in_section=0; inserted=0 }
    /^# / {
      if (in_section && !inserted) {
        print alias_line
        inserted=1
      }
      in_section=($2 == section)
    }
    in_section && $0 ~ "^alias " alias_name "=" { found=1 }
    in_section && !inserted && $0 ~ "^alias " {
      split($2, a, "=");
      if (alias_name < a[1]) {
        print alias_line
        inserted=1
      }
    }
    { print }
    END {
      if (in_section && !inserted && !found) print alias_line
    }
  ' "$ALIAS_FILE" > "$TMP_FILE"
else
  # Insert new section alphabetically
  awk -v section="$SECTION" -v alias_line="$ALIAS_LINE" '
    BEGIN { inserted=0 }
    /^# / {
      if (!inserted && section < substr($0,3)) {
        print "# " section
        print alias_line
        print ""
        inserted=1
      }
    }
    { print }
    END {
      if (!inserted) {
        print "# " section
        print alias_line
      }
    }
  ' "$ALIAS_FILE" > "$TMP_FILE"
fi

mv "$TMP_FILE" "$ALIAS_FILE" 