#!/bin/sh

xgettext -k_:1 -kn_:1,2 -ks_:1 -kns_:1,2 \
  -ki18n_gettext:2 -ki18n_ngettext:2,3 \
  -ki18n_sgettext:2 -ki18n_nsgettext:2,3 \
  -o messages.pot example.sh

