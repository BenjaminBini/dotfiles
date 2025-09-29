#!/usr/bin/env zsh

# Enable colors for the output
local green="\033[32m"
local red="\033[31m"
local reset="\033[0m"

check_status() {
  local name=$1
  local service_name=$2
  local process_name=$3

  local isServiceRunning=$(launchctl list | awk -v input="$service_name" '$3 ~ input {print $3}')
  if [[ -z "$isServiceRunning" ]]; then
    echo -e "🔴 $name service: ${red}Not Running${reset}"
  else
    echo -e "🟢 $name service: ${green}Running${reset}"
  fi

  local isProcessRunning=$(pgrep -x "$process_name")
  if [[ -n "$isProcessRunning" ]]; then
    echo -e "🟢 $name process: ${green}Running${reset}"
  else
    echo -e "🔴 $name process: ${red}Not Running${reset}"
  fi

  echo ""
}

check_status "Yabai" "yabai" "yabai"
check_status "Borders" "borders" "borders"
check_status "Skhd" "skhd" "skhd"
check_status "SketchyBar" "sketchybar" "sketchybar"