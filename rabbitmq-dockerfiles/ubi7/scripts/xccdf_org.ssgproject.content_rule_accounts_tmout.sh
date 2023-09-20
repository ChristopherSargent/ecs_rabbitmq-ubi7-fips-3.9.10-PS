#!/bin/sh
set -e

###############################################################################
# BEGIN fix for 'xccdf_org.ssgproject.content_rule_accounts_tmout'
###############################################################################
(>&2 echo "Remediating: 'xccdf_org.ssgproject.content_rule_accounts_tmout'")

var_accounts_tmout="600"

if grep --silent ^TMOUT /etc/profile ; then
        sed -i "s/^TMOUT.*/TMOUT=$var_accounts_tmout/g" /etc/profile
else
        echo -e "\n# Set TMOUT to $var_accounts_tmout per security requirements" >> /etc/profile
        echo "TMOUT=$var_accounts_tmout" >> /etc/profile
fi
# END fix for 'xccdf_org.ssgproject.content_rule_accounts_tmout'