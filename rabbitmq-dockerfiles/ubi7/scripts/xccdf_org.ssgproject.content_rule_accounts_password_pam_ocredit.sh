#!/bin/sh
set -e

###############################################################################
# BEGIN fix (17 / 24) for 'xccdf_org.ssgproject.content_rule_accounts_password_pam_ocredit'
###############################################################################
(>&2 echo "Remediating rule 17/${total}: 'xccdf_org.ssgproject.content_rule_accounts_password_pam_ocredit'")

var_password_pam_ocredit="-1"

function replace_or_append {
  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
  local config_file=$1
  local key=$2
  local value=$3
  local cce=$4
  local format=$5

  if [ "$case_insensitive_mode" = yes ]; then
    sed_case_insensitive_option="i"
    grep_case_insensitive_option="-i"
  fi
  [ -n "$format" ] || format="$default_format"
  # Check sanity of the input
  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
  # Otherwise, regular sed command will do.
  sed_command=('sed' '-i')
  if test -L "$config_file"; then
    sed_command+=('--follow-symlinks')
  fi

  # Test that the cce arg is not empty or does not equal @CCENUM@.
  # If @CCENUM@ exists, it means that there is no CCE assigned.
  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
    cce="CCE-${cce}"
  else
    cce="CCE"
  fi

  # Strip any search characters in the key arg so that the key can be replaced without
  # adding any search characters to the config file.
  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

  # shellcheck disable=SC2059
  printf -v formatted_output "$format" "$stripped_key" "$value"

  # If the key exists, change it. Otherwise, add it to the config_file.
  # We search for the key string followed by a word boundary (matched by \>),
  # so if we search for 'setting', 'setting2' won't match.
  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
  else
    # \n is precaution for case where file ends without trailing newline
    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
    printf '%s\n' "$formatted_output" >> "$config_file"
  fi
}

replace_or_append '/etc/security/pwquality.conf' '^ocredit' $var_password_pam_ocredit 'CCE-27360-7' '%s = %s'
# END fix for 'xccdf_org.ssgproject.content_rule_accounts_password_pam_ocredit'