#!/bin/sh

xgettext -k_:1 -kn_:1,2 -ks_:1 -kns_:1,2 -kp_:1c,2 -knp_:1c,2,3 \
  -ki18n_gettext:2 -ki18n_ngettext:2,3 \
  -ki18n_sgettext:2 -ki18n_nsgettext:2,3 \
  -ki18n_pgettext:2c,3 -ki18n_nsgettext:2c,3,4 \
  -o messages.pot example.sh

