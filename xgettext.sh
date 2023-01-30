#!/bin/sh

xgettext -k_:1 -kn_:1,2 -ks_:1 -kns_:1,2 \
  -kshgettext_gettext:2 -kshgettext_ngettext:2,3 \
  -kshgettext_sgettext:2 -kshgettext_nsgettext:2,3 \
  -o messages.pot example.sh

