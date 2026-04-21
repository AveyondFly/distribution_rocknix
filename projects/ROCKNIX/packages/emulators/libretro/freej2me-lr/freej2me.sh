#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2021-present 351ELEC (https://github.com/351ELEC)

. /etc/profile

clear > /dev/console

JDKDEST="/storage/jdk"

# Check if the jdk does not already exists
[ "$(ls -A ${JDKDEST})" ] && JDKINSTALLED="yes" || JDKINSTALLED="no"

if [ ${JDKINSTALLED} == "no" ]; then
  echo "Inflating JDK please be patient..." > /dev/console
  unzip -oq /usr/share/java/jdk.zip -d /roms/bios > /dev/console 2>&1
  echo "JDK done! loading core!" > /dev/console
  cp -rf /usr/config/game/freej2me/freej2me-lr.jar /storage/roms/bios
fi

clear > /dev/console < /dev/null 2>&1
exit 0
