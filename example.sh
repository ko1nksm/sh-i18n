#!/bin/sh
# shellcheck shell=bash disable=SC2016

set -eu

. "${0%/*}/lib/i18n.sh"

export TEXTDOMAIN="sh-i18n"
export TEXTDOMAINDIR="${0%/*}/locale"

# Used in some XSI-compliant environments (e.g. OpenIndiana)
export NLSPATH="${0%/*}/locale/%l/LC_MESSAGES/%N.mo"

echo "==== Basic ===="
_ 'Hello World.'
_ 'Hello, %s.' -- Ken
echo

echo "==== Plural forms ===="
n_ 'Here is %d apple.' 'Here are %d apples.' 2
n_ '%2$s has %1$d apple.' '%2$s has %1$d apples.' 1 Ken
echo

echo "==== Using backslash escape sequences ===="
_ $'Here is a tab =>\t<=.'
_ $'It\047s a small world.\n' -n
echo

echo "==== Locale-dependent numeric values ===="
_ "The distance from the earth to the sun is %'d km." 149597870000
_ "PI is %f." 3.1415926535
echo

echo "==== Use \$'...' for msgid that begin with \$. ===="
_ $'$100 is about %\047d Japanese yen.' $((100 * 130))
echo

echo "==== sgettext and nsgettext ===="
s_ 'File|Path'
s_ 'URL|Path'
ns_ 'File|Path (%d)' 'Paths (%d)' 1
ns_ 'URL|Path (%d)' 'Paths (%d)' 2
echo

echo "==== pgettext and npgettext ===="
p_ 'File' 'Path'
p_ 'URL' 'Path'
np_ 'File' 'Path (%d)' 'Paths (%d)' 1
np_ 'URL' 'Path (%d)' 'Paths (%d)' 2
echo
