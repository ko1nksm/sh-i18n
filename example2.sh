#!/bin/sh
# shellcheck shell=bash

set -eu

. "${0%/*}/lib/i18n.sh"

export TEXTDOMAIN="sh-i18n"
export TEXTDOMAINDIR="${0%/*}/locale"

# Used in some XSI-compliant environments (e.g. OpenIndiana)
export NLSPATH="${0%/*}/locale/%l/LC_MESSAGES/%N.mo"

if [ "${BASH_VERSION:-}" ]; then
  shopt -s expand_aliases
fi

echo "==== N_ ===="
N_ "Hello World."
echo
echo

echo "==== S_ ===="
S_ var "Hello World."
_ "$var"
echo

echo "==== @_ ===="
set --
{
  @_ "Positional Parameters 1"
  @_ "Positional Parameters 2"
  @_ "Positional Parameters 3"
}
for i in "$@"; do
  _ "$i"
done
echo

echo "==== V_ ===="
var=''
i18n_build_array var
{
  V_ "Variable Array 1"
  V_ "Variable Array 2"
  V_ "Variable Array 3"
}
i18n_set_array "$var"
for i in "$@"; do
  _ "$i"
done
echo

echo "==== A_ ===="
if ! { typeset -a ary || array ary; } 2>/dev/null; then
  echo "abort: array not supported."
  exit 0
fi
if [ "${YASH_VERSION:-}" ]; then
  array ary
else
  typeset -a ary 2>/dev/null
fi
i18n_build_array ary
{
  A_ "Array 1"
  A_ "Array 2"
  A_ "Array 3"
}
for i in "${ary[@]}"; do
  _ "$i"
done
echo

echo "==== AA_ ===="
if ! typeset -A aary 2>/dev/null; then
  echo "abort: associative array not supported."
  exit 0
fi
typeset -A aary
i18n_build_array aary
{
  AA_ key1 "Associative Array 1"
  AA_ key2 "Associative Array 2"
  AA_ key3 "Associative Array 3"
}
for i in "${aary[@]}"; do
  _ "$i"
done
echo
