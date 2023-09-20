#!/bin/sh
set -e

###############################################################################
# BEGIN fix (4 / 24) for 'xccdf_org.ssgproject.content_rule_accounts_minimum_age_login_defs'
###############################################################################
(>&2 echo "Remediating rule 4/${total}: 'xccdf_org.ssgproject.content_rule_accounts_minimum_age_login_defs'")

var_accounts_minimum_age_login_defs="1"

grep -q ^PASS_MIN_DAYS /etc/login.defs && \
  sed -i "s/PASS_MIN_DAYS.*/PASS_MIN_DAYS     $var_accounts_minimum_age_login_defs/g" /etc/login.defs
if ! [ $? -eq 0 ]; then
    echo "PASS_MIN_DAYS      $var_accounts_minimum_age_login_defs" >> /etc/login.defs
fi
# END fix for 'xccdf_org.ssgproject.content_rule_accounts_minimum_age_login_defs'