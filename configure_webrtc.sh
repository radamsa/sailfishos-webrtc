#!/bin/sh
TARGET_DIR="out/Release_arm"
#target_os="unix" 
gn gen $TARGET_DIR --args='target_cpu="arm" is_debug=false symbol_level=2 is_component_build=false is_clang=false linux_use_bundled_binutils=false treat_warnings_as_errors=false use_debug_fission=false use_gold=false use_cxx11=false use_custom_libcxx=false use_custom_libcxx_for_host=false use_sysroot=false proprietary_codecs=true rtc_build_json=true rtc_build_libevent=true rtc_build_libsrtp=true rtc_build_libvpx=true rtc_build_opus=true rtc_build_ssl=false rtc_ssl_root="/usr/include" rtc_enable_libevent=true rtc_enable_protobuf=false rtc_include_opus=true rtc_include_ilbc=true rtc_include_tests=false rtc_libvpx_build_vp9=true rtc_use_h264=true rtc_use_gtk=false use_system_libjpeg=true ffmpeg_branding="Chrome" rtc_use_x11=false use_x11=false rtc_build_examples=false is_component_ffmpeg=true libyuv_include_tests=false'
find $TARGET_DIR -type f -name '*.ninja' -exec sed -i 's/arm-linux-gnueabihf-//g' {} \;
find $TARGET_DIR -type f -name '*.ninja' -exec sed -i 's/\/arm-linux-gnueabihf//g' {} \;
