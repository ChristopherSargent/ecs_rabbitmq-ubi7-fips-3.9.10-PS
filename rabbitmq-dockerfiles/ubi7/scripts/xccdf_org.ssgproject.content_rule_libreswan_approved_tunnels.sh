#!/bin/sh
set -e

###############################################################################
# BEGIN fix (2 / 4) for 'xccdf_org.ssgproject.content_rule_libreswan_approved_tunnels'
###############################################################################
(>&2 echo "Remediating rule 2/${total}: 'xccdf_org.ssgproject.content_rule_libreswan_approved_tunnels'")
touch /etc/ipsec.conf /etc/ipsec.d

# END fix for 'xccdf_org.ssgproject.content_rule_libreswan_approved_tunnels'