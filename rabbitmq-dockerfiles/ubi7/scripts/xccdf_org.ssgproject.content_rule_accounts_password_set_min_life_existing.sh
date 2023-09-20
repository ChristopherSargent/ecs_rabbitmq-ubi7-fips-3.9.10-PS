#!/bin/sh
set -e

###############################################################################
# BEGIN fix (3 / 4) for 'xccdf_org.ssgproject.content_rule_accounts_password_set_min_life_existing'
###############################################################################
(>&2 echo "Remediating rule 3/${total}: 'xccdf_org.ssgproject.content_rule_accounts_password_set_min_life_existing'")
sed -i 's/PASS_MIN_DAYS\t0/PASS_MIN_DAYS    1/g' /etc/login.defs

# END fix for 'xccdf_org.ssgproject.content_rule_accounts_password_set_min_life_existing'