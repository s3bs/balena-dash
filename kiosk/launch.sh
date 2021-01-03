#!/bin/bash
pkill xinit

sleep 3

# delete the last line in xstart script and replace with new settings
sed -i '$d' /home/chromium/xstart.sh

if [ ! -z ${KIOSK_DEBUG+x} && [ "$KIOSK_DEBUG+x" -eq 1 ]
 then
   set -x
fi

_LOCAL_URL="$1"

if [ ! -z ${JITSI+x} ] && [ "$JITSI" -eq "1" ]
  then
    _LOCAL_URL="$_LOCAL_URL""$JITSI_FLAGS"
fi 

# Set whether to run Chromium in kiosk mode or not
if [ ! -z ${KIOSK+x} ] && [ "$KIOSK" -eq "1" ]
  then
    echo "Enabling kiosk mode"
    export CHROME_LAUNCH_URL=--app="'$_LOCAL_URL'" 
  else
    export CHROME_LAUNCH_URL="'$_LOCAL_URL'"
fi

# if the PERSISTENT enVar is set, add the appropriate flag
if [[ ! -z $PERSISTENT ]] && [[ "$PERSISTENT" -eq "1" ]]
  then
    echo "Adding user settings directory"
    FLAGS="$FLAGS --user-data-dir=/data"

    # make sure any lock on the Chromium profile is released
    chown -R chromium:chromium /data
    rm -f /data/SingletonLock
fi

echo "chromium-browser $CHROME_LAUNCH_URL $KIOSK $FLAGS --window-size=$WINDOW_SIZE" >> /home/chromium/xstart.sh

set +x 

# run script as chromium user
su -c "export DISPLAY=:$DISPLAY && startx /home/chromium/xstart.sh $CURSOR $OUTPUT" - chromium
