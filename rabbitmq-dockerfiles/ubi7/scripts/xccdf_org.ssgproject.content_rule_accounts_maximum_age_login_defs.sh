#!/bin/sh
set -e

###############################################################################
# BEGIN fix (5 / 24) for 'xccdf_org.ssgproject.content_rule_accounts_maximum_age_login_defs'
###############################################################################
(>&2 echo "Remediating rule 5/${total}: 'xccdf_org.ssgproject.content_rule_accounts_maximum_age_login_defs'")

var_accounts_maximum_age_login_defs="60"

grep -q ^PASS_MAX_DAYS /etc/login.defs && \
  sed -i "s/PASS_MAX_DAYS.*/PASS_MAX_DAYS     $var_accounts_maximum_age_login_defs/g" /etc/login.defs
if ! [ $? -eq 0 ]; then
    echo "PASS_MAX_DAYS      $var_accounts_maximum_age_login_defs" >> /etc/login.defs
fi
# END fix for 'xccdf_org.ssgproject.content_rule_accounts_maximum_age_login_defs'