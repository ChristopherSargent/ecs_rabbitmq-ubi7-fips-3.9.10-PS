#!/bin/sh
set -e

###############################################################################
# BEGIN fix for 'xccdf_org.ssgproject.content_rule_clean_components_post_updating'
###############################################################################
(>&2 echo "Remediating: 'xccdf_org.ssgproject.content_rule_clean_components_post_updating'")

if grep --silent ^clean_requirements_on_remove /etc/yum.conf ; then
        sed -i "s/^clean_requirements_on_remove.*/clean_requirements_on_remove=1/g" /etc/yum.conf
else
        echo -e "\n# Set clean_requirements_on_remove to 1 per security requirements" >> /etc/yum.conf
        echo "clean_requirements_on_remove=1" >> /etc/yum.conf
fi
# END fix for 'xccdf_org.ssgproject.content_rule_clean_components_post_updating'