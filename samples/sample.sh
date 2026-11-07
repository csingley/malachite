#!/usr/bin/env bash
# GPU health check: a theme sample, not a real script.
#
# Shell highlights differ from other languages: command names, flags, variables,
# redirections and heredocs all need to be distinguishable.

# TODO: this is a TODO comment, the tag should stand out
# NOTE: a NOTE comment; FIXME and HACK are the other tags

set -euo pipefail
shopt -s nullglob extglob

readonly SCRIPT_NAME="${0##*/}"                  # parameter expansion, a readonly variable
readonly LOG_DIR="${LOG_DIR:-/var/log/gpu}"      # default value expansion
readonly MAX_TEMP=85                             # a number
declare -A THRESHOLDS=([util]=90 [mem]=95)       # an associative array
declare -a HOSTS=(gpu-01 gpu-02 "gpu 03")        # an indexed array with a quoted element
KEYWORDS_AS_TEXT='if then else fi for while do done case esac'   # keywords inside a string

log() {                                          # function definition
  local level="$1"; shift                        # local is a builtin that declares
  printf '%s [%s] %s\n' "$(date -Iseconds)" "$level" "$*" >&2
}

usage() {
  cat <<EOF                                      # unquoted heredoc: $SCRIPT_NAME expands
Usage: $SCRIPT_NAME [-v] [-t SECONDS] HOST...
  -v          verbose
  -t SECONDS  per-host timeout (default: ${TIMEOUT:-30})
EOF
}

die() { log ERROR "$@"; exit 1; }

check_host() {
  local host="$1" temp util rc=0
  if ! ssh -o ConnectTimeout=5 "$host" true 2>/dev/null; then   # a command, flags, a redirect
    log WARN "cannot reach $host"
    return 1
  fi
  temp=$(ssh "$host" gpu-query --field=temperature --format=csv,noheader | head -n1)
  util=$(ssh "$host" gpu-query --field=utilization --format=csv,noheader,nounits)
  if [[ $temp -gt $MAX_TEMP && "$util" != 0 ]]; then            # test brackets and operators
    log ERROR "$host is hot: ${temp}C at ${util}%"
    rc=2
  elif (( temp > MAX_TEMP - 10 )); then                         # arithmetic evaluation
    log INFO "$host is warm: $((temp + 0))C"
  fi
  return "$rc"
}

main() {
  local verbose=0 timeout=30 opt
  while getopts ':vt:h' opt; do                                 # control flow keywords
    case "$opt" in
      v) verbose=1 ;;
      t) timeout="$OPTARG" ;;
      h) usage; exit 0 ;;
      \?) die "unknown option: -$OPTARG" ;;
    esac
  done
  shift $((OPTIND - 1))

  [[ $# -gt 0 ]] || set -- "${HOSTS[@]}"
  trap 'log INFO "interrupted"; exit 130' INT TERM               # builtin with a quoted command

  local failed=0
  for host in "$@"; do
    check_host "$host" || failed=$((failed + 1))
  done

  grep -E 'ERROR|WARN' "$LOG_DIR"/*.log 2>/dev/null \
    | awk '{print $3}' | sort -u | tee >(wc -l > /tmp/count.$$)   # pipes, process substitution
  echo "failed: $failed" && return "$failed"
}

cmd=$(command -v gpu-query || true)                            # command substitution
echo -e 'tab:\there' $'ansi:\x1b[0m' "glob: ${HOSTS[@]:0:2} ~/logs/*.log"   # escapes, globs, tilde

main "$@"

# ---- lines the UI-state script looks for -------------------------------------------------
echo "$undefined_variable"                                      # DIAG: error  (unbound variable)
unused_var=1                                                    # DIAG: warn   (assigned but unused)
cat file | grep pattern                                         # DIAG: info   (useless use of cat)
[ -n "$HOSTS" ]                                                 # DIAG: hint   (prefer [[ ]])
SEARCH_TARGET="retry retry retry"                               # SEARCH: retry
