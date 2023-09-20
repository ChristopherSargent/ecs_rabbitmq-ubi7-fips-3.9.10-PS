#!/bin/sh
set -e

###############################################################################
# BEGIN fix (1 / 24) for 'xccdf_org.ssgproject.content_rule_no_empty_passwords'
###############################################################################
(>&2 echo "Remediating rule 1/${total}: 'xccdf_org.ssgproject.content_rule_no_empty_passwords'")
sed --follow-symlinks -i 's/\<nullok\>//g' /etc/pam.d/system-auth
sed --follow-symlinks -i 's/\<nullok\>//g' /etc/pam.d/password-auth
# END fix for 'xccdf_org.ssgproject.content_rule_no_empty_passwords'