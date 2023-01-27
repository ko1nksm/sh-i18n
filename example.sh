#!/bin/sh

set -eu

. "${0%/*}/lib/sh-gettext.sh"

export TEXTDOMAIN="sh-gettext-example"
export TEXTDOMAINDIR="${0%/*}/locale"

echo "==== Basic ===="
_ 'Hello World.'
_ 'Hello, %s.' -- Ken
echo

echo "==== Plural forms ===="
_n 'Here is %d apple.' 'Here are %d apples.' 2
_n '%2$s has %1$d apple.' '%2$s has %1$d apples.' 1 Ken
echo

echo "==== Using backslash escape sequences ===="
_ $'Here is a tab =>\t<=.'
_ $'It\047s a small world.\n' -n
echo

echo "==== Using decimal separator ===="
_ "The distance from the earth to the sun is %'d km." 149597870000
echo

echo "==== Use \$'...' for msgid that begin with \$. ===="
_ $'$100 is about %\047d Japanese yen.' $((100 * 130))

