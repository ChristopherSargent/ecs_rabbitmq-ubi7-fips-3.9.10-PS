# Utilize the image from download.yaml
# This is because we need to download the latest image from Red Hat. Current
# implementation for doing ARG based FROM instructions require replacing
# the FROM with an already existing image (i.e. one we've previously built).
# This prevents us from retrieving the latest image from Red Hat.
FROM registry.access.redhat.com/ubi7/ubi:7.9

COPY scripts/*.sh /dsop-fix/

COPY yum.repos.d/ /etc/yum.repos.d

# CAS tools, install vi, vim and less to make the image more useful
RUN yum -y update && yum -y install && \
	vim && \
	less && \
	vi 
#  CAS tools 2, add enablefips.bash and datetime.sh. enablefips.bash allows fips-mode-setup --check to return FIPS mode is enabled. versus default ironback ubi8 which returns FIPS mode is enabled Inconsistent state detected, note this script came from redhat and reference can be found here https://access.redhat.com/discussions/3487481. datetime.sh adds a time stampt to bash history and the terminal and creates a bash alias for ll.
RUN yum update -y && \
    /scripts/enablefips.bash && \
    /scripts/datetime.sh 

COPY banner/issue /etc/

RUN echo Update packages and install DISA STIG fixes && \
    echo "exclude=redhat-release-server" >> /etc/yum.conf && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-* && \
    # Disable all repositories (to limit RHEL host repositories) and only use official UBI repositories
    sed -i "s/enabled=1/enabled=0/" /etc/yum/pluginconf.d/subscription-manager.conf && \
    rm -f /etc/yum.repos.d/ubi.repo && \
    yum repolist && \
    yum update -y && \
    # Do not use loops to iterate through shell scripts, this allows for scripts to fail
    # but the build to still be successful. Be explicit when executing scripts and ensure
    # that all scripts have "set -e" at the top of the bash file!
    /dsop-fix/xccdf_org.ssgproject.content_rule_account_disable_post_pw_expiration.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_logon_fail_delay.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_max_concurrent_login_sessions.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_maximum_age_login_defs.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_minimum_age_login_defs.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_dcredit.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_difok.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_lcredit.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_maxclassrepeat.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_maxrepeat.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_minclass.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_minlen.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_ocredit.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_ucredit.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_unix_remember.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_set_max_life_existing.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_set_min_life_existing.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_deny.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_deny_root.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_interval.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_unlock_time.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_tmout.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_clean_components_post_updating.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_ensure_gpgcheck_local_packages.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_libreswan_approved_tunnels.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_no_empty_passwords.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_rpm_verify_permissions.sh && \
    yum clean all && \
    rm -rf /var/cache/yum/ /var/tmp/* /tmp/* /var/tmp/.???* /tmp/.???*

ENV container oci
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Purposely not setting USER as this is a builder image 
CMD ["/bin/bash"]
