#!/bin/sh
export PLATFORM_SDK_ROOT=/srv/mer
curl -k -O http://releases.sailfishos.org/sdk/installers/latest/Jolla-latest-SailfishOS_Platform_SDK_Chroot-i486.tar.bz2 ;
sudo mkdir -p $PLATFORM_SDK_ROOT/sdks/sfossdk ;
sudo tar --numeric-owner -p -xjf Jolla-latest-SailfishOS_Platform_SDK_Chroot-i486.tar.bz2 -C $PLATFORM_SDK_ROOT/sdks/sfossdk  ;
echo "export PLATFORM_SDK_ROOT=$PLATFORM_SDK_ROOT" >> ~/.bashrc
echo 'alias sfossdk=$PLATFORM_SDK_ROOT/sdks/sfossdk/mer-sdk-chroot' >> ~/.bashrc ; exec bash ;
echo 'PS1="PlatformSDK $PS1"' > ~/.mersdk.profile ;
echo '[ -d /etc/bash_completion.d ] && for i in /etc/bash_completion.d/*;do . $i;done'  >> ~/.mersdk.profile ;
