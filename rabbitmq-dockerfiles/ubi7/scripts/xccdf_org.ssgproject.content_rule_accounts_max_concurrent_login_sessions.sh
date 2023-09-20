#!/bin/sh
set -e

###############################################################################
# BEGIN fix for 'xccdf_org.ssgproject.content_rule_accounts_max_concurrent_login_sessions'
###############################################################################
(>&2 echo "Remediating: 'xccdf_org.ssgproject.content_rule_accounts_max_concurrent_login_sessions'")

var_accounts_max_concurrent_login_sessions="10"

if grep -q '^[^#]*\<maxlogins\>' /etc/security/limits.d/*.conf; then
	sed -i "/^[^#]*\<maxlogins\>/ s/maxlogins.*/maxlogins $var_accounts_max_concurrent_login_sessions/" /etc/security/limits.d/*.conf
elif grep -q '^[^#]*\<maxlogins\>' /etc/security/limits.conf; then
	sed -i "/^[^#]*\<maxlogins\>/ s/maxlogins.*/maxlogins $var_accounts_max_concurrent_login_sessions/" /etc/security/limits.conf
else
	echo "*	hard	maxlogins	$var_accounts_max_concurrent_login_sessions" >> /etc/security/limits.conf
fi
# END fix for 'xccdf_org.ssgproject.content_rule_accounts_max_concurrent_login_sessions'