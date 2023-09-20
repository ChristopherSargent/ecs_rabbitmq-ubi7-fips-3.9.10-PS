#!/bin/sh
set -e

###############################################################################
# BEGIN fix (7 / 24) for 'xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_unlock_time'
###############################################################################
(>&2 echo "Remediating rule 7/${total}: 'xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_unlock_time'")

var_accounts_passwords_pam_faillock_unlock_time="never"

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

function set_faillock_option_to_value_in_pam_file {
	# If invoked with no arguments, exit. This is an intentional behavior.
	[ $# -gt 1 ] || return 0
	[ $# -ge 3 ] || die "$0 requires exactly zero, three, or four arguments"
	[ $# -le 4 ] || die "$0 requires exactly zero, three, or four arguments"
	local _pamFile="$1" _option="$2" _value="$3" _insert_lines_callback="$4"
	# pam_faillock.so already present?
	if grep -q "^auth.*pam_faillock.so.*" "$_pamFile"; then

		# pam_faillock.so present, is the option present?
		if grep -q "^auth.*[default=die].*pam_faillock.so.*authfail.*$_option=" "$_pamFile"; then

			# both pam_faillock.so & option present, just correct option to the right value
			sed -i --follow-symlinks "s/\(^auth.*required.*pam_faillock.so.*preauth.*silent.*\)\($_option *= *\).*/\1\2$_value/" "$_pamFile"
			sed -i --follow-symlinks "s/\(^auth.*[default=die].*pam_faillock.so.*authfail.*\)\($_option *= *\).*/\1\2$_value/" "$_pamFile"

		# pam_faillock.so present, but the option not yet
		else

			# append correct option value to appropriate places
			sed -i --follow-symlinks "/^auth.*required.*pam_faillock.so.*preauth.*silent.*/ s/$/ $_option=$_value/" "$_pamFile"
			sed -i --follow-symlinks "/^auth.*[default=die].*pam_faillock.so.*authfail.*/ s/$/ $_option=$_value/" "$_pamFile"
		fi

	# pam_faillock.so not present yet
	else
		test -z "$_insert_lines_callback" || "$_insert_lines_callback" "$_option" "$_value" "$_pamFile"
		# insert pam_faillock.so preauth & authfail rows with proper value of the option in question
	fi
}

function insert_lines_if_pam_faillock_so_not_present {
	local _option="$1" _value="$2" _pamFile="$3"
	sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/i auth        required      pam_faillock.so preauth silent $_option=$_value" "$_pamFile"
	sed -i --follow-symlinks "/^auth.*sufficient.*pam_unix.so.*/a auth        [default=die] pam_faillock.so authfail $_option=$_value" "$_pamFile"
	sed -i --follow-symlinks "/^account.*required.*pam_unix.so/i account     required      pam_faillock.so" "$_pamFile"
}

for pamFile in "${AUTH_FILES[@]}"
do
	# 'true &&' has to be there due to build system limitation
	true && set_faillock_option_to_value_in_pam_file "$pamFile" unlock_time "$var_accounts_passwords_pam_faillock_unlock_time" insert_lines_if_pam_faillock_so_not_present
done
# END fix for 'xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_unlock_time'