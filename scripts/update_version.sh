#!/bin/bash

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] version

Update version

Available options:

   version      Target version
-h, --help      Print this help and exit
EOF
  exit
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  flag=0

  args=("$@")

  while :; do
    echo "$1" | grep -E '^(\d+\.\d+\.\d+(?:-.+)?)$' > /dev/null
    local _status=$?
    if [ "$_status" -eq 0 ]; then
      version="$1"
      shift
      continue
    fi

    case "${1-}" in
    -h | --help) usage ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  # check required params and arguments
  [[ -z "${version}" ]] && die "Missing required parameter: version"
  [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  return 0
}

update_podspec_version() {
  sed -i '' -E 's/(spec\.version += +)\"[^\"]+\"/\1\"'${version}'\"/g' ./Chronograph.podspec
}

update_xcodeproj_version() {
  sed -i '' -E 's/(MARKETING_VERSION += +)[^;]+;/\1'${version}';/g' ./Chronograph.xcodeproj/project.pbxproj
}

main() {
  update_podspec_version
  update_xcodeproj_version
}

parse_params $@
main
