#!/bin/sh

xgettext \
  -k_:1 -kn_:1,2 -ks_:1 -kns_:1,2 -kp_:1c,2 -knp_:1c,2,3 \
  -kN_ -kS_:2 -k@_ -kV_ -kA_ -kAA_:2 \
  -ki18n_gettext:2 -ki18n_ngettext:2,3 \
  -ki18n_sgettext:2 -ki18n_nsgettext:2,3 \
  -ki18n_pgettext:2c,3 -ki18n_nsgettext:2c,3,4 \
  -ki18n_gettext_noop -ki18n_gettext_s2v:2 \
  -ki18n_gettext_a2v -ki18n_gettext_a2a -ki18n_gettext_a2aa:2 \
  -o messages.pot example.sh example2.sh

