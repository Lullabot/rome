#!/bin/bash

# Uninstall all unused kernels. Headers and such will be handled by the next
# autoremove command.
current=`uname -r` && uninstall="" && for version in `dpkg -l linux-image* | grep ii | awk '{ print $2}'`; do if [[ "$version" < "linux-image-$current" ]]; then uninstall=$uninstall" $version"; fi; done && sudo apt-get purge $uninstall -y && sudo update-grub2

