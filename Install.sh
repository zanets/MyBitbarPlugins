#!/bin/bash

mkdir -p ~/.Bitbar/Plugins/

[ -x "$(command -v smc)" ] || ( curl -LO http://www.eidac.de/smcfancontrol/smcfancontrol_2_4.zip \
  && unzip -d temp_dir_smc smcfancontrol_2_4.zip \
  && cp temp_dir_smc/smcFanControl.app/Contents/Resources/smc /usr/local/bin/smc ; rm -rf temp_dir_smc smcfancontrol_2_4.zip )

ln -s $(pwd)/Plugins/*.sh ~/.Bitbar/Plugins