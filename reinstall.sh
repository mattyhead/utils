#!/bin/bash
date
rm ~/.wp-cli/cache/plugin* -Rf
cd ~/public_html
wp plugin deactivate pv-machine-inspector-signup  pv-core
wp plugin uninstall pv-machine-inspector-signup pv-core
wp plugin install https://github.com/mattyhead/pv-core/archive/master.zip --activate
wp plugin install https://github.com/mattyhead/pv-machine-inspector-signup/archive/master.zip --activate

