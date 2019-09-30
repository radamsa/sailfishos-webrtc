!!! ВНИМАНИЕ !!! В процессе подготовки и установки исходников WebRTC потребуется скачать более 15Гб.
----------------------------------------------------------------------------------------------------


# Подготовка (только версия для armv7hl):

1. Устанавливаем SDK и утилиты для кросскомпиляции:
export PLATFORM_SDK_ROOT=/srv/mer
curl -k -O http://releases.sailfishos.org/sdk/installers/latest/Jolla-latest-SailfishOS_Platform_SDK_Chroot-i486.tar.bz2 ;
sudo mkdir -p $PLATFORM_SDK_ROOT/sdks/sfossdk ;
sudo tar --numeric-owner -p -xjf Jolla-latest-SailfishOS_Platform_SDK_Chroot-i486.tar.bz2 -C $PLATFORM_SDK_ROOT/sdks/sfossdk  ;
echo "export PLATFORM_SDK_ROOT=$PLATFORM_SDK_ROOT" >> ~/.bashrc
echo 'alias sfossdk=$PLATFORM_SDK_ROOT/sdks/sfossdk/mer-sdk-chroot' >> ~/.bashrc ; exec bash ;
echo 'PS1="PlatformSDK $PS1"' > ~/.mersdk.profile ;
echo '[ -d /etc/bash_completion.d ] && for i in /etc/bash_completion.d/*;do . $i;done'  >> ~/.mersdk.profile ;

2. Заходим в среду кросскомпиляции:
sfossdk

3. Устанавливаем утилиты внутри среды кросскомпиляции:
```bash
sb2 -m sdk-install -R zypper in git alsa-lib alsa-lib-devel pulseaudio pulseaudio-devel
```

# Компилируем WebRTC (начинаем вне среды кросскомпиляции):
-- Каждый раз при входе в среду кросскомпиляции потребуется восстанавливать переменную PATH так, чтобы были доступны depot_tools
-- Список переменных, передаваемых внутри строки --args при конфигурации (gn gen...), можно посмотреть в файлах BUILD.gn

```bash
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH=$PATH:$(pwd)/depot_tools
mkdir webrtc && cd webrtc
GYP_DEFINES="target_arch=arm" fetch --no-history webrtc
pushd src
gn gen out/Release --args='is_debug=false rtc_use_h264=true ffmpeg_branding="Chrome" rtc_include_tests=false rtc_enable_protobuf=false is_clang=false target_cpu="arm" treat_warnings_as_errors=false rtc_use_x11=false is_clang=false use_gold=false'

gn gen out/Release --args='is_debug=false rtc_use_h264=true ffmpeg_branding="Chrome" rtc_include_tests=false rtc_enable_protobuf=false is_clang=false target_cpu="arm" treat_warnings_as_errors=false rtc_use_x11=false is_clang=false linux_use_bundled_binutils=false use_debug_fission=false use_gold=false use_cxx11=true use_custom_libcxx=false use_custom_libcxx_for_host=false proprietary_codecs=true rtc_build_json=true rtc_build_libevent=true rtc_build_libsrtp=true rtc_build_libvpx=true rtc_build_opus=true rtc_enable_libevent=true rtc_enable_protobuf=false rtc_include_opus=true rtc_include_ilbc=true rtc_include_tests=false rtc_libvpx_build_vp9=true rtc_use_h264=true use_system_libjpeg=true'

pushd out/Release
find -type f -name '*.ninja' -exec sed -i 's/arm-linux-gnueabihf-//g' {} \;
find -type f -name '*.ninja' -exec sed -i 's/\/arm-linux-gnueabihf//g' {} \;
popd
sfossdk
export PATH=$PATH:/home/dav/projects/depot_tools
sb2 -m sdk-build ninja -C out/Release
```

### error:
```
[220/2868] CXX obj/buildtools/third_party/libc++abi/libc++abi/cxa_personality.o
FAILED: obj/buildtools/third_party/libc++abi/libc++abi/cxa_personality.o 
g++ -MMD -MF obj/buildtools/third_party/libc++abi/libc++abi/cxa_personality.o.d -DLIBCXXABI_SILENT_TERMINATE -D_LIBCPP_ENABLE_CXX17_REMOVED_UNEXPECTED_FUNCTIONS -DUSE_UDEV -DUSE_AURA=1 -DUSE_GLIB=1 -DUSE_NSS_CERTS=1 -DUSE_X11=1 -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_LIBCPP_ABI_UNSTABLE -D_LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS -D_LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS -D_LIBCPP_ENABLE_NODISCARD -DCR_LIBCXX_REVISION=361348 -DCR_SYSROOT_HASH=ef5c4f84bcafb7a3796d36bb1db7826317dde51c -DNDEBUG -DNVALGRIND -DDYNAMIC_ANNOTATIONS_ENABLED=0 -I../.. -Igen -fno-strict-aliasing --param=ssp-buffer-size=4 -fstack-protector -funwind-tables -fPIC -pipe -pthread -march=armv7-a -mfloat-abi=hard -mtune=generic-armv7-a -Wno-builtin-macro-redefined -D__DATE__= -D__TIME__= -D__TIMESTAMP__= -mfpu=neon -mthumb -O2 -fno-ident -fdata-sections -ffunction-sections -fno-omit-frame-pointer -g0 -fno-builtin-abs -fvisibility=hidden -Wno-psabi -Wno-unused-local-typedefs -Wno-maybe-uninitialized -Wno-deprecated-declarations -Wno-comments -Wno-packed-not-aligned -Wno-missing-field-initializers -Wno-unused-parameter -fstrict-aliasing -fPIC -std=gnu++14 -nostdinc++ -isystem../../buildtools/third_party/libc++/trunk/include -isystem../../buildtools/third_party/libc++abi/trunk/include --sysroot=../../build/linux/debian_sid_arm-sysroot -fvisibility-inlines-hidden -Wno-narrowing -Wno-class-memaccess -fexceptions -frtti -c ../../buildtools/third_party/libc++abi/trunk/src/cxa_personality.cpp -o obj/buildtools/third_party/libc++abi/libc++abi/cxa_personality.o
../../buildtools/third_party/libc++abi/trunk/src/cxa_personality.cpp: In function ‘void __cxxabiv1::scan_eh_tab(__cxxabiv1::{anonymous}::scan_results&, _Unwind_Action, bool, _Unwind_Control_Block*, _Unwind_Context*)’:
../../buildtools/third_party/libc++abi/trunk/src/cxa_personality.cpp:573:22: error: ‘_URC_FATAL_PHASE1_ERROR’ was not declared in this scope
     results.reason = _URC_FATAL_PHASE1_ERROR;
                      ^
../../buildtools/third_party/libc++abi/trunk/src/cxa_personality.cpp:593:30: error: ‘_URC_FATAL_PHASE2_ERROR’ was not declared in this scope
             results.reason = _URC_FATAL_PHASE2_ERROR;
                              ^
../../buildtools/third_party/libc++abi/trunk/src/cxa_personality.cpp: In function ‘_Unwind_Reason_Code __cxxabiv1::__gxx_personality_v0(_Unwind_State, _Unwind_Control_Block*, _Unwind_Context*)’:
../../buildtools/third_party/libc++abi/trunk/src/cxa_personality.cpp:1098:16: error: ‘_URC_FATAL_PHASE1_ERROR’ was not declared in this scope
         return _URC_FATAL_PHASE1_ERROR;
                ^
../../buildtools/third_party/libc++abi/trunk/src/cxa_personality.cpp:1111:11: error: invalid conversion from ‘int’ to ‘_Unwind_State’ [-fpermissive]
     state &= ~_US_FORCE_UNWIND;
           ^
../../buildtools/third_party/libc++abi/trunk/src/cxa_personality.cpp:1191:12: error: ‘_URC_FATAL_PHASE1_ERROR’ was not declared in this scope
     return _URC_FATAL_PHASE1_ERROR;
            ^
At global scope:
cc1plus: warning: unrecognized command line option "-Wno-class-memaccess"
cc1plus: warning: unrecognized command line option "-Wno-packed-not-aligned"
[222/2868] CXX obj/buildtools/third_party/libc++/libc++/locale.o
```

#### fix:
[https://reviews.llvm.org/D53127]
[https://reviews.llvm.org/D53127?id=169553#inline-469029]
в файле cxa_exception.hpp в строке 30 (перед началом структуры struct _LIBCXXABI_HIDDEN __cxa_exception) добавить
```c++
#if defined(__arm__) && defined(__ARM_EABI_UNWINDER__)
// missing values from _Unwind_Reason_Code enum
#define _URC_FATAL_PHASE2_ERROR ((_Unwind_Reason_Code)2)
#define _URC_FATAL_PHASE1_ERROR ((_Unwind_Reason_Code)3)
#define _URC_NORMAL_STOP ((_Unwind_Reason_Code)4)
#endif
```

в файле cxa_personality.cpp в строке 1112 заменить
```c++
    state &= ~_US_FORCE_UNWIND;
```
на
```c++
    state = (_Unwind_State)(state & ~_US_FORCE_UNWIND);
```

### error:
```
[123/2645] CXX obj/modules/rtp_rtcp/rtp_rtcp/time_util.o
FAILED: obj/modules/rtp_rtcp/rtp_rtcp/time_util.o 
g++ -MMD -MF obj/modules/rtp_rtcp/rtp_rtcp/time_util.o.d -DBWE_TEST_LOGGING_COMPILE_TIME_ENABLE=0 -DUSE_UDEV -DUSE_AURA=1 -DUSE_GLIB=1 -DUSE_NSS_CERTS=1 -DUSE_X11=1 -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D_FORTIFY_SOURCE=2 -D_LIBCPP_ABI_UNSTABLE -D_LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS -D_LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS -D_LIBCPP_ENABLE_NODISCARD -DCR_LIBCXX_REVISION=361348 -DCR_SYSROOT_HASH=ef5c4f84bcafb7a3796d36bb1db7826317dde51c -DNDEBUG -DNVALGRIND -DDYNAMIC_ANNOTATIONS_ENABLED=0 -DWEBRTC_ENABLE_PROTOBUF=0 -DWEBRTC_INCLUDE_INTERNAL_AUDIO_DEVICE -DRTC_ENABLE_VP9 -DHAVE_SCTP -DWEBRTC_USE_H264 -DWEBRTC_ARCH_ARM -DWEBRTC_ARCH_ARM_V7 -DWEBRTC_HAS_NEON -DWEBRTC_LIBRARY_IMPL -DWEBRTC_NON_STATIC_TRACE_EVENT_HANDLERS=0 -DWEBRTC_POSIX -DWEBRTC_LINUX -DABSL_ALLOCATOR_NOTHROW=1 -I../.. -Igen -I../../third_party/abseil-cpp -I../../third_party/libyuv/include -fno-strict-aliasing --param=ssp-buffer-size=4 -fstack-protector -funwind-tables -fPIC -pipe -pthread -march=armv7-a -mfloat-abi=hard -mtune=generic-armv7-a -Wno-builtin-macro-redefined -D__DATE__= -D__TIME__= -D__TIMESTAMP__= -mfpu=neon -mthumb -Wall -Wno-psabi -Wno-unused-local-typedefs -Wno-maybe-uninitialized -Wno-deprecated-declarations -Wno-comments -Wno-packed-not-aligned -Wno-missing-field-initializers -Wno-unused-parameter -O2 -fno-ident -fdata-sections -ffunction-sections -fno-omit-frame-pointer -g0 -fno-builtin-abs -fvisibility=hidden -Wextra -Wno-unused-parameter -Wno-missing-field-initializers -std=gnu++14 -Wno-narrowing -Wno-class-memaccess -fno-exceptions -fno-rtti -nostdinc++ -isystem../../buildtools/third_party/libc++/trunk/include -isystem../../buildtools/third_party/libc++abi/trunk/include --sysroot=../../build/linux/debian_sid_arm-sysroot -fvisibility-inlines-hidden -Wnon-virtual-dtor -Woverloaded-virtual -c ../../modules/rtp_rtcp/source/time_util.cc -o obj/modules/rtp_rtcp/rtp_rtcp/time_util.o
In file included from ../../modules/rtp_rtcp/source/time_util.cc:16:0:
../../rtc_base/numerics/divide_round.h: In instantiation of ‘constexpr auto webrtc::DivideRoundToNearest(Dividend, Divisor) [with Dividend = long long int; Divisor = long long int]’:
../../modules/rtp_rtcp/source/time_util.cc:74:55:   required from here
../../rtc_base/numerics/divide_round.h:44:1: error: body of constexpr function ‘constexpr auto webrtc::DivideRoundToNearest(Dividend, Divisor) [with Dividend = long long int; Divisor = long long int]’ not a return-statement
 }
 ^
../../rtc_base/numerics/divide_round.h: In instantiation of ‘constexpr auto webrtc::DivideRoundToNearest(Dividend, Divisor) [with Dividend = long long int; Divisor = int]’:
../../modules/rtp_rtcp/source/time_util.cc:90:58:   required from here
../../rtc_base/numerics/divide_round.h:44:1: error: body of constexpr function ‘constexpr auto webrtc::DivideRoundToNearest(Dividend, Divisor) [with Dividend = long long int; Divisor = int]’ not a return-statement
cc1plus: warning: unrecognized command line option "-Wno-class-memaccess"
cc1plus: warning: unrecognized command line option "-Wno-packed-not-aligned"
[125/2645] CXX obj/modules/rtp_rtcp/rtp_rtcp/source_tracker.o
```
#### fix:
В файле src/rtc_base/numerics/divide_round.h заменить функции DivideRoundUp и DivideRoundToNearest на следующий код
```c++
template <typename Dividend, typename Divisor>
inline auto constexpr DivideRoundUp(Dividend dividend, Divisor divisor) {
  return (dividend / divisor) + (dividend % divisor > 0 ? 1 : 0);
}

template <typename Dividend, typename Divisor>
inline auto constexpr DivideRoundToNearest(Dividend dividend, Divisor divisor) {
  return (dividend / divisor) + (rtc::SafeGt(dividend % divisor, ((divisor - 1) / 2)) ? 1 : 0);
}
```

### error:
```
[1792/2863] ASM obj/third_party/boringssl/boringssl_asm/vpaes-armv7.o
FAILED: obj/third_party/boringssl/boringssl_asm/vpaes-armv7.o 
gcc -MMD -MF obj/third_party/boringssl/boringssl_asm/vpaes-armv7.o.d -DUSE_UDEV -DUSE_AURA=1 -DUSE_GLIB=1 -DUSE_NSS_CERTS=1 -DUSE_X11=1 -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D_FORTIFY_SOURCE=2 -D_LIBCPP_ABI_UNSTABLE -D_LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS -D_LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS -D_LIBCPP_ENABLE_NODISCARD -DCR_LIBCXX_REVISION=361348 -DCR_SYSROOT_HASH=ef5c4f84bcafb7a3796d36bb1db7826317dde51c -DNDEBUG -DNVALGRIND -DDYNAMIC_ANNOTATIONS_ENABLED=0 -I../../third_party/boringssl/src/include -I../.. -Igen -fPIC -fno-strict-aliasing --param=ssp-buffer-size=4 -fstack-protector -funwind-tables -fPIC -pipe -pthread -std=gnu11 -march=armv7-a -mfloat-abi=hard -mtune=generic-armv7-a -mfpu=neon -g0 --sysroot=../../build/linux/debian_sid_arm-sysroot -c ../../third_party/boringssl/linux-arm/crypto/fipsmodule/vpaes-armv7.S -o obj/third_party/boringssl/boringssl_asm/vpaes-armv7.o
{standard input}: Assembler messages:
{standard input}: Error: .size expression for _vpaes_decrypt_consts does not evaluate to a constant
[1794/2863] CXX obj/third_party/boringssl/boringssl/tls_record.o
ninja: build stopped: subcommand failed.
```
#### fix:
???
