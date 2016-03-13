#!/usr/bin/env bash
# -*- encoding: utf-8 -*-
# Copyright (c) 2014 Pivotal Software, Inc. All Rights Reserved.

set -e

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/lib/prelude_apply.bash

# Install Google Daemon and Google Startup Scripts packages
mkdir -p $chroot/tmp
if [ -f $chroot/etc/debian_version ] # Ubuntu
then
  cp $assets_dir/google-compute-daemon_1.3.3-1_all.deb $chroot/tmp
  cp $assets_dir/google-startup-scripts_1.3.3-1_all.deb $chroot/tmp

  run_in_chroot $chroot "dpkg -i /tmp/google-compute-daemon_1.3.3-1_all.deb /tmp/google-startup-scripts_1.3.3-1_all.deb || true"
  pkg_mgr install

  # Avoid collissions recreating the host keys
  run_in_chroot $chroot "rm -fr /usr/share/google/regenerate-host-keys"

  rm -f /tmp/google-compute-daemon_1.3.3-1_all.deb
  rm -f /tmp/google-startup-scripts_1.3.3-1_all.deb
elif [ -f $chroot/etc/redhat-release ] # Centos or RHEL
then
  cp $assets_dir/google-compute-daemon-1.3.3-1.noarch.rpm $chroot/tmp
  cp $assets_dir/google-startup-scripts-1.3.3-1.noarch.rpm $chroot/tmp

  run_in_chroot $chroot "yum -y install /tmp/google-compute-daemon-1.3.3-1.noarch.rpm /tmp/google-startup-scripts-1.3.3-1.noarch.rpm"

  # Hack: enable systemd google services (rpm control script does not detect systemd)
  run_in_chroot $chroot "/bin/systemctl enable /usr/lib/systemd/system/google-accounts-manager.service"
  run_in_chroot $chroot "/bin/systemctl enable /usr/lib/systemd/system/google-address-manager.service"
  run_in_chroot $chroot "/bin/systemctl enable /usr/lib/systemd/system/google-clock-sync-manager.service"

  # Avoid collissions recreating the host keys
  run_in_chroot $chroot "rm -fr /usr/share/google/regenerate-host-keys"

  rm -f /tmp/google-compute-daemon-1.3.3-1.noarch.rpm
  rm -f /tmp/google-startup-scripts-1.3.3-1.noarch.rpm
else
  echo "Unknown OS, exiting"
  exit 2
fi
