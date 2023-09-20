###############################################################################
# BEGIN fix (10 / 24) for 'xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_deny'
###############################################################################
(>&2 echo "Remediating rule 10/${total}: 'xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_deny'")

var_accounts_passwords_pam_faillock_deny="3"

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

# This script fixes absence of pam_faillock.so in PAM stack or the
# absense of deny=[0-9]+ in pam_faillock.so arguments
# When inserting auth pam_faillock.so entries,
# the entry with preauth argument will be added before pam_unix.so module
# and entry with authfail argument will be added before pam_deny.so module.

# The placement of pam_faillock.so entries will not be changed
# if they are already present

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

function insert_lines_if_pam_faillock_so_not_present_other {
	# insert pam_faillock.so preauth row with proper value of the 'deny' option before pam_unix.so
	sed -i --follow-symlinks "/^auth.*pam_unix.so.*/i auth        required      pam_faillock.so preauth silent $_option=$_value" $_pamFile
	# insert pam_faillock.so authfail row with proper value of the 'deny' option before pam_deny.so, after all modules which determine authentication outcome.
	sed -i --follow-symlinks "/^auth.*pam_deny.so.*/i auth        [default=die] pam_faillock.so authfail $_option=$_value" $_pamFile
}

for pamFile in "${AUTH_FILES[@]}"
do
	# 'true &&' has to be there due to build system limitation
	true && set_faillock_option_to_value_in_pam_file "$pamFile" deny "$var_accounts_passwords_pam_faillock_deny" insert_lines_if_pam_faillock_so_not_present_other

	# add pam_faillock.so into account phase
	if ! grep -q "^account.*required.*pam_faillock.so" $pamFile; then
		sed -i --follow-symlinks "/^account.*required.*pam_unix.so/i account     required      pam_faillock.so" $pamFile
	fi
done
# END fix for 'xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_deny'