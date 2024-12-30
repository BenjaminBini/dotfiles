###
### UTILS
###

# shellcheck disable=SC2034
red="\033[91m"
# shellcheck disable=SC2034
green="\033[92m"
# shellcheck disable=SC2034
blue="\033[94m"
# shellcheck disable=SC2034
yellow="\033[93m"
# shellcheck disable=SC2034
white="\033[97m"
# shellcheck disable=SC2034
no_color="\033[0m"
gray="\033[90m"


## check if /tmp dir exists


print_discreet_no_nl() {
    echo "${gray}=>${no_color}${gray}" "${@}" "${no_color}" >&1
}

print_discreet() {
    echo "${gray}=>${no_color}${gray}" "${@}" "${no_color}" >&1
}
print_msg() {
    echo "${green}=>${no_color}${white}" "${@}" "${no_color}" >&1
}

print_warning() {
    echo "${yellow}=> WARNING:${no_color}${white}" "${@}" "${no_color}" >&2
}

print_error() {
    echo "${red}=> ERROR:${no_color}${white}" "${@}" "${no_color}" >&2
}

print_header() {
    echo "${blue}
       _     _   ___ _ _
     _| |___| |_|  _|_| |___ ___
   _| . | . |  _|  _| | | -_|_ -|
  |_|___|___|_| |_| |_|_|___|___|${yellow}

  BOOTSTRAP SCRiPT${white}
  ${git_url}${git_repo}${no_color}
" >&1
}
