#!/bin/sh
# Usage: ./sort_zsh_aliases.sh ~/.zsh_aliases > ~/.zsh_aliases.sorted

awk '
function trim(s) { sub(/^ +| +$/, "", s); return s }
BEGIN { section = ""; }
/^#/ {
  if (section != "") {
    print_section(section, section_lines)
    delete section_lines
  }
  section = $0
  next
}
{
  section_lines[NR] = $0
}
END {
  if (section != "") {
    print_section(section, section_lines)
  }
}
function print_section(header, lines,   i, n, aliases, others, alias_file) {
  print "###SECTION###"
  print header
  n = 0
  for (i in lines) n++
  a = 0; o = 0
  for (i in lines) {
    line = lines[i]
    if (line ~ /^alias[ \t]/) {
      aliases[++a] = line
    } else if (trim(line) != "") {
      others[++o] = line
    }
  }
  for (i = 1; i <= o; i++) print others[i]
  if (a > 0) {
    alias_file = "/tmp/aliases_sort_" PROCINFO["pid"]
    for (i = 1; i <= a; i++) print aliases[i] > alias_file
    close(alias_file)
    while (( "sort " alias_file ) | getline sorted_line ) print sorted_line
    close("sort " alias_file)
    system("rm -f " alias_file)
  }
  print ""
}
' "$1" | awk 'BEGIN{RS="###SECTION###\n"; ORS=""} NR>1{print $0 > ("/tmp/section_" NR)}'
# Now sort the section files by their header and concatenate
for f in $(ls /tmp/section_* | xargs grep -H '^#' | sort -t: -k2 | cut -d: -f1 | uniq); do
  cat "$f"
done
rm -f /tmp/section_*
