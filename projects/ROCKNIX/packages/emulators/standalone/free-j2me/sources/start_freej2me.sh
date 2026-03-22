#!/bin/bash
. /etc/profile
. /etc/os-release

arguments="$@"

EMULATOR="${arguments##*--emulator=}"  # read from --emulator= onwards
EMULATOR="${EMULATOR%% *}"  # until a space is found

ROMNAME="${1}"


if [[ "${EMULATOR}" = "libretro" ]]; then
	/usr/bin/runemu.sh "$@"
else

if [ ! -f "/storage/.config/java/sdl_interface" ]; then
    cp -rf /usr/config/java /storage/.config/
fi

GAME_HOME=/storage/.config/java
GAME_JAR=$GAME_HOME/freej2me-sdl.jar

cd $GAME_HOME

# 如果 /storage/jdk 不存在，创建软连接指向 /roms/bios/jdk
if [ ! -e "/storage/jdk" ]; then
    ln -sf /roms/bios/jdk /storage/jdk
fi

JAVA_HOME='/storage/jdk'
export JAVA_HOME
PATH="$JAVA_HOME/bin:$PATH"
export PATH

mkdir -p ./.java/.systemPrefs
mkdir -p ./.java/.userPrefs
chmod -R 755 ./.java

export SDL_GAMECONTROLLERCONFIG_FILE=/storage/.config/SDL-GameControllerDB/gamecontrollerdb.txt
gptokeyb -k sdl_interface -c ./j2me.gptk --killsignal 15&

export LANG="zh_CN.UTF-8"

#JAVA_TOOL_OPTIONS='-Xverify:none -Djava.util.prefs.systemRoot=/storage/roms/savestates/j2me/ -Djava.util.prefs.userRoot=/storage/roms/savestates/j2me/ -Djava.awt.headless=true -Dsun.jnu.encoding=UTF-8 -Dfile.encoding=UTF-8 -Djava.library.path=/storage/java/lib'
JAVA_TOOL_OPTIONS='-Xverify:none -Djava.awt.headless=true -Dsun.jnu.encoding=UTF-8 -Dfile.encoding=UTF-8 -Djava.library.path=/storage/.config/java/lib'
export JAVA_TOOL_OPTIONS

#jslisten set "java"


gamedir=`dirname "$1"`

java -jar $GAME_JAR "$1"

kill -9 `pidof gptokeyb`

fi
