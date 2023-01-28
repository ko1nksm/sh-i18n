# shellcheck shell=sh

: "${SHGETTEXT_PRINTF:=}" "${SHGETTEXT_DECIMALPOINT:=.}"
: "${SHGETTEXT_GETTEXT:=gettext}" "${SHGETTEXT_NGETTEXT:=ngettext}"

shgettext_setup() {
  shgettext_work="${TEXTDOMAIN+x}${TEXTDOMAIN:-}"

  if "$SHGETTEXT_GETTEXT" -E '' >/dev/null 2>&1; then
    # Probably GNU gettext or POSIX gettext.
    shgettext__gettext() { "$SHGETTEXT_GETTEXT" -E "$1"; }
  elif type "$SHGETTEXT_GETTEXT" >/dev/null 2>&1; then
    # Implementation without -E option.
    # Probably Solaris 10/11.
    shgettext__gettext() {
      shgettext__replace_all shgettext_work "$1" "\\" "\\\\"
      set -- "$shgettext_work"
      unset shgettext_work
      "$SHGETTEXT_GETTEXT" -e "$1"
    }
  else
    # gettext is not installed.
    shgettext__gettext() { shgettext__put "$1"; }
  fi

  if type "$SHGETTEXT_NGETTEXT" >/dev/null 2>&1; then
    # gettext is installed.
    shgettext__ngettext() { "$SHGETTEXT_NGETTEXT" -E "$1" "$2" "$3"; }
  else
    # gettext is not installed.
    shgettext__ngettext() {
      [ "$3" = '1' ] || shift
      shgettext__put "$1"
    }
  fi

  case $shgettext_work in
    ?) TEXTDOMAIN=${shgettext_work#x} ;;
    *) unset TEXTDOMAIN ;;
  esac

  if [ "${KSH_VERSION:-}" ]; then
    shgettext__put() {
      IFS=" $IFS" && set -- "$*" && IFS=${IFS# }
      command print -nr -- "${1:-}"
    }

    shgettext__putln() {
      IFS=" $IFS" && set -- "$*" && IFS=${IFS# }
      command print -r -- "${1:-}"
    }
  else
    shgettext__put() {
      IFS=" $IFS" && set -- "$*" && IFS=${IFS# }
      command printf '%s' "${1:-}"
    }

    shgettext__putln() {
      IFS=" $IFS" && set -- "$*" && IFS=${IFS# }
      command printf '%s\n' "${1:-}"
    }
  fi

  if [ "$(command printf -- x)" = 'x' ]; then
    # shellcheck disable=SC2059
    shgettext__native_printf() { command printf -- "$@"; }
  else
    # shellcheck disable=SC2059
    shgettext__native_printf() { command printf "$@"; }
  fi

  shgettext__printf() {
   "${SHGETTEXT_PRINTF:-shgettext__native_printf}" "$@"
  }

  if shgettext__printf "%'d" 0 >/dev/null 2>&1; then
    shgettext__printf_is_decimal_separator_supported() { true; }
  else
    shgettext__printf_is_decimal_separator_supported() { false; }
  fi
}
shgettext_setup

shgettext_detect_decimal_point() {
  set -- "$(printf "%1.1f" 1)" 2>/dev/null
  SHGETTEXT_DECIMALPOINT=${1:-1.0}
  SHGETTEXT_DECIMALPOINT=${SHGETTEXT_DECIMALPOINT#1}
  SHGETTEXT_DECIMALPOINT=${SHGETTEXT_DECIMALPOINT%0}
}
shgettext_detect_decimal_point

# shellcheck disable=SC3003
if [ $':' = '$:' ]; then
  # For shells not supporting $'...'

  # shgettext_gettext MSGID
  shgettext_gettext() {
    case $1 in (\$*)
      shgettext__unescape shgettext_work "${1#\$}"
      set -- "$shgettext_work"
    esac
    unset shgettext_work
    shgettext__gettext "$1"
  }

  # shgettext_ngettext MSGID MSGID-PLURAL N
  shgettext_ngettext() {
    case $1 in (\$*)
      shgettext__unescape shgettext_work "${1#\$}"
      set -- "$shgettext_work" "$2" "$3"
    esac
    case $2 in (\$*)
      shgettext__unescape shgettext_work "${2#\$}"
      set -- "$1" "$shgettext_work" "$3"
    esac
    unset shgettext_work
    shgettext__ngettext "$1" "$2" "$3"
  }
else
  # For shells supporting $'...'
  shgettext_gettext() { shgettext__gettext "$1"; }
  shgettext_ngettext() { shgettext__ngettext "$1" "$2" "$3"; }
fi

# shellcheck disable=SC2016
shgettext__generate_unescape() {
  printf '%s\n' \
    'shgettext__unescape() {' \
    '  set -- "$1" "$2\\" ""' \
    '  while set -- "$1" "${2#*\\}" "${3}${2%%\\*}" && [ "$2" ]; do' \
    '    case $2 in'

  set -- n \\0012 t \\0011 r \\0015 a \\0007 b \\0010 f \\0014 v \\0013
  printf '      %s*) set -- "$1" "${2#?}" "${3}%b" ;;\n' '\\' '\0134\0134' "$@"

  set -- && i=0
  while [ "$i" -lt 127 ] && i=$((i + 1)); do
    j=$((i / 64))$(((i % 64) / 8))$((i % 8))
    case $j in
      042 | 044 | 134 | 140) set -- "$@" "$j" "\\\\\\0$j" ;;
      *) set -- "$@" "$j" "\\0$j" ;;
    esac
  done
  printf '      %s*) set -- "$1" "${2#???}" "${3}%b" ;;\n' "$@"

  set -- && i=0
  while [ "$i" -lt 63 ] && i=$((i + 1)); do
    j=$(((i % 64) / 8))$((i % 8))
    case $j in
      42 | 44) set -- "$@" "$j" "\\\\\\0$j" ;;
      *) set -- "$@" "$j" "\\0$j" ;;
    esac
  done
  printf '      %s*) set -- "$1" "${2#??}" "${3}%b" ;;\n' "$@"

  set -- 1 \\0001 2 \\0002 3 \\0003 4 \\0004 5 \\0005 6 \\0006 7 \\0007
  printf '      %s*) set -- "$1" "${2#?}" "${3}%b" ;;\n' "$@"

  printf '%s\n' \
    '      *) set -- "$1" "${2#?}" "${3}\\${2%"${2#?}"}" ;;' \
    '    esac' \
    '  done' \
    '  eval "$1=\$3"' \
    '}'
}
eval "$(shgettext__generate_unescape)"

if (eval ": \"\${PPID//?/}\"") 2>/dev/null; then
  # Not POSIX shell compliant but fast
  shgettext__replace_all() {
    eval "$1=\${2//\"\$3\"/\"\$4\"}"
  }
else
  # For POSIX Shells
  shgettext__replace_all() {
    set -- "$1" "$2$3" "$3" "$4" ""
    while [ "$2" ]; do
      set -- "$1" "${2#*"$3"}" "$3" "$4" "$5${2%%"$3"*}$4"
    done
    eval "$1=\${5%\"\$4\"}"
  }
fi

shgettext_printf() {
  shgettext__printf_args_reorder shgettext_work "$1" $(($# - 1))
  eval "shift; set -- \"\${shgettext_work%@*}\" ${shgettext_work##*@}"
  shgettext__printf_format_manipulater shgettext_work "${shgettext_work%@*}"
  shift
  set -- "$@" "${shgettext_work%@*}"
  shgettext_work=${shgettext_work##*@}
  while [ "$shgettext_work" ]; do
    case $shgettext_work in
      +*) set -- "$@" "${1%%[,.]*}$SHGETTEXT_DECIMALPOINT${1#*[,.]}" ;;
      *) set -- "$@" "$1" ;;
    esac
    shift
    shgettext_work=${shgettext_work#* }
  done
  unset shgettext_work
  shgettext__printf "$@"
}

shgettext__printf_args_reorder() {
  set -- "$1" "$2%" "$3" '' '' 1
  while [ "$2" ]; do
    set -- "$1" "${2#*\%}" "$3" "$4${2%%\%*}%" "$5" "$6"
    case $2 in
      '') continue ;;
      %*) set -- "$1" "${2#%}" "$3" "$4%" "$5" "$6" && continue ;;
    esac

    if shgettext__printf_format_is_parameter_field shgettext_work "$2"; then
      set -- "$1" "${2#*\$}" "$3" "$4" "$5" "$6" "$shgettext_work"
      set -- "$@" $((${7#"${7%%[!0]*}"}+0))
      if [ 1 -le "$8" ] && [ "$8" -le "$3" ]; then
        set -- "$1" "$2" "$3" "$4" "$5 \"\${$8}\"" "$6"

        if shgettext__printf_format_is_flags_field shgettext_work "$2"; then
          if ! shgettext__printf_is_decimal_separator_supported; then
            set -- "$1" "$2" "$3" "$4" "$5" "$6" "$shgettext_work"
            shgettext__replace_all shgettext_work "$7" "'" ""
            set -- "$1" "$shgettext_work${2#"$7"}" "$3" "$4" "$5" "$6"
          fi
        fi
      else
        set -- "$1" "$2" "$3" "$4%$7\$" "$5" "$6"
      fi
      continue
    fi

    if shgettext__printf_format_is_flags_field shgettext_work "$2"; then
      if ! shgettext__printf_is_decimal_separator_supported; then
        set -- "$1" "$2" "$3" "$4" "$5" "$6" "$shgettext_work"
        shgettext__replace_all shgettext_work "$7" "'" ""
        set -- "$1" "$shgettext_work${2#"$7"}" "$3" "$4" "$5" "$6"
      fi
    fi

    if [ "$6" -le "$3" ]; then
      set -- "$1" "$2" "$3" "$4" "$5 \"\${$6:-}\"" $(($6 + 1))
    else
      set -- "$1" "$2" "$3" "$4%" "$5" $(($6 + 1))
    fi
  done
  unset shgettext_work
  eval "$1=\"\${4%\%}@\${5}\""
}

shgettext__printf_format_is_parameter_field() {
  set -- "$1" "$2" "${2%%\$*}"
  [ "$2" = "$3" ] && return 1
  case $3 in
    *[!0-9]*) return 1
  esac
  eval "$1=\$3"
}

shgettext__printf_format_is_flags_field() {
  set -- "$1" "$2" "${2%%[!-+ 0\'\#]*}"
  [ "$3" ] || return 1
  eval "$1=\$3"
}

shgettext__printf_format_manipulater() {
  set -- "$1" "$2%" '' '' ''
  while [ "$2" ]; do
    set -- "$1" "${2#*\%}" "$3${2%%\%*}%" "$4"
    case $2 in
      '') continue ;;
      %*) set -- "$1" "${2#%}" "$3%" "$4" && continue ;;
      *)
        case $2 in ([-+\ 0\'\#]*) # flags
          set -- "$1" "$2" "$3" "$4" "${2%%[!-+ 0\'\#]*}"
          set -- "$1" "${2#"$5"}" "$3$5" "$4"
        esac
        case $2 in ([0-9]*) # width
          set -- "$1" "$2" "$3" "$4" "${2%%[!0-9]*}"
          set -- "$1" "${2#"$5"}" "$3$5" "$4"
        esac
        case $2 in (.*) # precision
          set -- "$1" "${2#.}" "$3." "$4"
          set -- "$1" "$2" "$3" "$4" "${2%%[!0-9]*}"
          set -- "$1" "${2#"$5"}" "$3$5" "$4"
        esac
        case $2 in # length + type
          [fFeEgG]* | [hlL][fFeEgG]*) set -- "$1" "$2" "$3" "$4+ " ;;
          *) set -- "$1" "$2" "$3" "$4- " ;;
        esac
        set -- "$1" "$2" "$3" "$4"
    esac
  done
  eval "$1=\"\${3%\%}@\${4}\""
}

# shgettext_print MSGID [-n | --] [ARGUMENT]...
shgettext_print() {
  shgettext_work=$(shgettext_gettext "$1" && echo x)
  shgettext__replace_all shgettext_work "${shgettext_work%x}" "\\" "\\\\"
  case ${2:-} in
    -n) shift 2 && set -- "$shgettext_work" "$@" ;;
    --) shift 2 && set -- "$shgettext_work\n" "$@" ;;
     *) shift 1 && set -- "$shgettext_work\n" "$@" ;;
  esac
  unset shgettext_work
  shgettext_printf "$@"
}

# shgettext_nprint MSGID MSGID-PLURAL [-n | --] N [ARGUMENT]...
shgettext_nprint() {
  case $3 in
    -n | --) shgettext_work=$(shgettext_ngettext "$1" "$2" "$4" && echo x) ;;
    *) shgettext_work=$(shgettext_ngettext "$1" "$2" "$3" && echo x) ;;
  esac
  shgettext__replace_all shgettext_work "${shgettext_work%x}" "\\" "\\\\"
  case $3 in
    -n) shift 3 && set -- "$shgettext_work" "$@" ;;
    --) shift 3 && set -- "$shgettext_work\n" "$@" ;;
     *) shift 2 && set -- "$shgettext_work\n" "$@" ;;
  esac
  unset shgettext_work
  shgettext_printf "$@"
}

# shgettext_echo STRING
shgettext_echo() { shgettext__putln "$1"; }

_() { shgettext_print "$@"; }
_n() { shgettext_nprint "$@"; }
