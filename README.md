!!! ВНИМАНИЕ !!! В процессе подготовки и установки исходников WebRTC потребуется скачать более 15Гб.
----------------------------------------------------------------------------------------------------

# 1. Устанавливаем SDK и утилиты для кросскомпиляции (только версия для armv7hl)
## 1.1. Устанавливаем SDK [https://sailfishos.org/wiki/Platform_SDK_Installation]
```bash
export PLATFORM_SDK_ROOT=/srv/mer
curl -k -O http://releases.sailfishos.org/sdk/installers/latest/Jolla-latest-SailfishOS_Platform_SDK_Chroot-i486.tar.bz2 ;
sudo mkdir -p $PLATFORM_SDK_ROOT/sdks/sfossdk ;
sudo tar --numeric-owner -p -xjf Jolla-latest-SailfishOS_Platform_SDK_Chroot-i486.tar.bz2 -C $PLATFORM_SDK_ROOT/sdks/sfossdk  ;
echo "export PLATFORM_SDK_ROOT=$PLATFORM_SDK_ROOT" >> ~/.bashrc
echo 'alias sfossdk=$PLATFORM_SDK_ROOT/sdks/sfossdk/mer-sdk-chroot' >> ~/.bashrc ; exec bash ;
echo 'PS1="PlatformSDK $PS1"' > ~/.mersdk.profile ;
echo '[ -d /etc/bash_completion.d ] && for i in /etc/bash_completion.d/*;do . $i;done'  >> ~/.mersdk.profile ;
```

## 1.2. Устанавливаем утилиты для кросскомпиляции (только версия для armv7hl) [https://sailfishos.org/wiki/Platform_SDK_Target_Installation]
Перейти в SDK shell (выполнить sfossdk), а затем выполнить следующие команды:
```bash
sdk-assistant create SailfishOS-latest http://releases.sailfishos.org/sdk/targets/Sailfish_OS-latest-Sailfish_SDK_Tooling-i486.tar.7z
sdk-assistant create SailfishOS-latest-armv7hl http://releases.sailfishos.org/sdk/targets/Sailfish_OS-latest-Sailfish_SDK_Target-armv7hl.tar.7z
```
## 1.3. Можно установить еще и утилиты для кросскомпиляции в i486
```bash
sdk-assistant create SailfishOS-latest-i486 http://releases.sailfishos.org/sdk/targets/Sailfish_OS-latest-Sailfish_SDK_Target-i486.tar.7z
```
*если установлено несколько версий утилит кросскомпиляции, то следует указывать, какой набор будет использован при запуске sb2*
*например, sb2 -t SailfishOS-latest-armv7hl -m sdk-install zypper in ...*


# 2. Устанавливаем утилиты внутри среды кросскомпиляции
Перейти в SDK shell (выполнить sfossdk), а затем выполнить следующие команды:
```bash
sb2 -m sdk-install -R zypper in git alsa-lib-devel pulseaudio-devel openssl-devel libjpeg-turbo-devel ninja
#sb2 -m sdk-install -R zypper in git alsa-lib pulseaudio openssl libjpeg-turbo
```

*далее следует выбрать, какая версия WebRTC будет собираться (2.1 или 2.2). после выбора и настройки пеерходим к п. 2.3*

# 3. Настраиваем поледнюю версию WebRTC
## 3.1. Устанавливаем утилиты для компиляции WebRTC
## 3.2. Конфигурация для branch-heads/59
```bash
GYP_DEFINES="target_arch=arm" fetch --no-history webrtc
echo "target_os = ['unix']" >> .gclient
cd src

# строка для конфигурирования последней версии WebRTC
gn gen out/Release --args='is_debug=false symbol_level=2 is_component_build=false is_clang=false linux_use_bundled_binutils=false treat_warnings_as_errors=false use_debug_fission=false use_gold=false use_cxx11=false use_custom_libcxx=false use_custom_libcxx_for_host=false use_sysroot=false proprietary_codecs=true rtc_build_json=true rtc_build_libevent=true rtc_build_libsrtp=true rtc_build_libvpx=true rtc_build_opus=true rtc_build_ssl=false rtc_ssl_root="/usr/include" rtc_enable_libevent=true rtc_enable_protobuf=false rtc_include_opus=true rtc_include_ilbc=true rtc_include_tests=false rtc_libvpx_build_vp9=true rtc_use_h264=true rtc_use_gtk=false use_system_libjpeg=true ffmpeg_branding="Chrome" target_cpu="arm" rtc_use_x11=false use_x11=false rtc_build_examples=false is_component_ffmpeg=true libyuv_include_tests=false'
```

## 3.3. Конфигурация для branch-heads/59
```bash
gn gen out/arm --args='is_debug=false symbol_level=2 is_component_build=false is_clang=false linux_use_bundled_binutils=false treat_warnings_as_errors=false use_debug_fission=false use_gold=false use_sysroot=false proprietary_codecs=true rtc_build_json=true rtc_build_libevent=true rtc_build_libsrtp=true rtc_build_libvpx=true rtc_build_opus=true rtc_build_ssl=false rtc_ssl_root="/usr/include" rtc_enable_libevent=true rtc_enable_protobuf=false rtc_include_opus=true rtc_include_ilbc=true rtc_include_tests=false rtc_libvpx_build_vp9=true rtc_use_h264=true rtc_use_gtk=false use_system_libjpeg=true ffmpeg_branding="Chrome" target_cpu="arm" is_component_ffmpeg=true libyuv_include_tests=false'
```

### PlanB
```bash
gn gen out/arm --args='is_debug=false symbol_level=2 is_component_build=false is_clang=false linux_use_bundled_binutils=false treat_warnings_as_errors=false use_debug_fission=false use_gold=false use_sysroot=false proprietary_codecs=true rtc_build_json=true rtc_build_libevent=true rtc_build_libsrtp=true rtc_build_libvpx=true rtc_build_opus=true rtc_enable_libevent=true rtc_enable_protobuf=false rtc_include_opus=true rtc_include_ilbc=true rtc_include_tests=false rtc_libvpx_build_vp9=true rtc_use_h264=true rtc_use_gtk=false use_system_libjpeg=true ffmpeg_branding="Chrome" target_cpu="arm" is_component_ffmpeg=true libyuv_include_tests=false'
```

## 2.2. Готовимся к компиляции
*скорректируем имена используемых компиляторов/утилит*
```bash
find out/Release_arm -type f -name '*.ninja' -exec sed -i 's/arm-linux-gnueabihf-//g' {} \;
find out/Release_arm -type f -name '*.ninja' -exec sed -i 's/\/arm-linux-gnueabihf//g' {} \;
```

## 2.4. Собственно компиляция
```bash
sfossdk
#? export PATH=$PATH:/home/dav/projects/depot_tools
sb2 -m sdk-build ninja -C out/Release
```

## 2.5. Возможные ошибки при компиляции:
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
[579/2719] CXX obj/modules/audio_processing/audio_processing/normalized_covariance_estimator.o
FAILED: obj/modules/audio_processing/audio_processing/normalized_covariance_estimator.o 
g++ -MMD -MF obj/modules/audio_processing/audio_processing/normalized_covariance_estimator.o.d -DWEBRTC_NS_FIXED -DUSE_UDEV -DUSE_AURA=1 -DUSE_GLIB=1 -DUSE_NSS_CERTS=1 -DUSE_X11=1 -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D_FORTIFY_SOURCE=2 -DNDEBUG -DNVALGRIND -DDYNAMIC_ANNOTATIONS_ENABLED=0 -DWEBRTC_ENABLE_PROTOBUF=0 -DWEBRTC_INCLUDE_INTERNAL_AUDIO_DEVICE -DRTC_ENABLE_VP9 -DHAVE_SCTP -DWEBRTC_USE_H264 -DWEBRTC_ARCH_ARM -DWEBRTC_ARCH_ARM_V7 -DWEBRTC_HAS_NEON -DWEBRTC_APM_DEBUG_DUMP=0 -DWEBRTC_LIBRARY_IMPL -DWEBRTC_NON_STATIC_TRACE_EVENT_HANDLERS=0 -DWEBRTC_POSIX -DWEBRTC_LINUX -DABSL_ALLOCATOR_NOTHROW=1 -I../.. -Igen -I../../third_party/abseil-cpp -fno-strict-aliasing --param=ssp-buffer-size=4 -fstack-protector -funwind-tables -fPIC -pipe -pthread -march=armv7-a -mfloat-abi=hard -mtune=generic-armv7-a -Wno-builtin-macro-redefined -D__DATE__= -D__TIME__= -D__TIMESTAMP__= -mfpu=neon -mthumb -Wall -Wno-psabi -Wno-unused-local-typedefs -Wno-maybe-uninitialized -Wno-deprecated-declarations -Wno-comments -Wno-packed-not-aligned -Wno-missing-field-initializers -Wno-unused-parameter -O2 -fno-ident -fdata-sections -ffunction-sections -fno-omit-frame-pointer -gdwarf-3 -g2 -fvisibility=hidden -Wextra -Wno-unused-parameter -Wno-missing-field-initializers -std=gnu++14 -Wno-narrowing -Wno-class-memaccess -fno-exceptions -fno-rtti -fvisibility-inlines-hidden -Wnon-virtual-dtor -Woverloaded-virtual -c ../../modules/audio_processing/echo_detector/normalized_covariance_estimator.cc -o obj/modules/audio_processing/audio_processing/normalized_covariance_estimator.o
In file included from ../../modules/audio_processing/echo_detector/normalized_covariance_estimator.cc:15:0:
../../modules/audio_processing/echo_detector/normalized_covariance_estimator.cc: In member function ‘void webrtc::NormalizedCovarianceEstimator::Update(float, float, float, float, float, float)’:
../../modules/audio_processing/echo_detector/normalized_covariance_estimator.cc:34:34: error: ‘isfinite’ was not declared in this scope
   RTC_DCHECK(isfinite(covariance_));
                                  ^
../../rtc_base/checks.h:311:26: note: in definition of macro ‘RTC_EAT_STREAM_PARAMETERS’
   (true ? true : ((void)(ignored), true))                         \
                          ^
../../modules/audio_processing/echo_detector/normalized_covariance_estimator.cc:34:3: note: in expansion of macro ‘RTC_DCHECK’
   RTC_DCHECK(isfinite(covariance_));
   ^
../../modules/audio_processing/echo_detector/normalized_covariance_estimator.cc:34:34: note: suggested alternative:
   RTC_DCHECK(isfinite(covariance_));
                                  ^
../../rtc_base/checks.h:311:26: note: in definition of macro ‘RTC_EAT_STREAM_PARAMETERS’
   (true ? true : ((void)(ignored), true))                         \
                          ^
../../modules/audio_processing/echo_detector/normalized_covariance_estimator.cc:34:3: note: in expansion of macro ‘RTC_DCHECK’
   RTC_DCHECK(isfinite(covariance_));
   ^
In file included from /srv/mer/toolings/SailfishOS-latest/opt/cross/armv7hl-meego-linux-gnueabi/include/c++/4.9.4/random:38:0,
                 from /srv/mer/toolings/SailfishOS-latest/opt/cross/armv7hl-meego-linux-gnueabi/include/c++/4.9.4/bits/stl_algo.h:66,
                 from /srv/mer/toolings/SailfishOS-latest/opt/cross/armv7hl-meego-linux-gnueabi/include/c++/4.9.4/algorithm:62,
                 from ../../third_party/abseil-cpp/absl/strings/string_view.h:30,
                 from ../../rtc_base/checks.h:46,
                 from ../../modules/audio_processing/echo_detector/normalized_covariance_estimator.cc:15:
/srv/mer/toolings/SailfishOS-latest/opt/cross/armv7hl-meego-linux-gnueabi/include/c++/4.9.4/cmath:601:5: note:   ‘std::isfinite’
     isfinite(_Tp __x)
     ^
At global scope:
cc1plus: warning: unrecognized command line option "-Wno-class-memaccess"
cc1plus: warning: unrecognized command line option "-Wno-packed-not-aligned"
[581/2719] CXX obj/modules/audio_processing/audio_processing/gain_control_for_experimental_agc.o
ninja: build stopped: subcommand failed.
```
#### fix:
Нужно скорректировать вызов RTC_DCHECK(isfinite... дбавив имя пространства имен std::
Получится  RTC_DCHECK(std::isfinite...

### error:
```
[1136/2719] CXX obj/test/perf_test/perf_test.o
../../test/testsupport/perf_test.cc: In member function ‘std::string {anonymous}::PerfResultsLogger::UnitWithDirection(const string&, webrtc::test::ImproveDirection)’:
../../test/testsupport/perf_test.cc:214:3: warning: control reaches end of non-void function [-Wreturn-type]
   }
   ^
At global scope:
cc1plus: warning: unrecognized command line option "-Wno-class-memaccess"
cc1plus: warning: unrecognized command line option "-Wno-packed-not-aligned"
[1692/2719] ASM obj/third_party/boringssl/boringssl_asm/vpaes-armv7.o
FAILED: obj/third_party/boringssl/boringssl_asm/vpaes-armv7.o 
gcc -MMD -MF obj/third_party/boringssl/boringssl_asm/vpaes-armv7.o.d -DUSE_UDEV -DUSE_AURA=1 -DUSE_GLIB=1 -DUSE_NSS_CERTS=1 -DUSE_X11=1 -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D_FORTIFY_SOURCE=2 -DNDEBUG -DNVALGRIND -DDYNAMIC_ANNOTATIONS_ENABLED=0 -I../../third_party/boringssl/src/include -I../.. -Igen -fPIC -fno-strict-aliasing --param=ssp-buffer-size=4 -fstack-protector -funwind-tables -fPIC -pipe -pthread -std=gnu11 -march=armv7-a -mfloat-abi=hard -mtune=generic-armv7-a -mfpu=neon -gdwarf-3 -g2 -c ../../third_party/boringssl/linux-arm/crypto/fipsmodule/vpaes-armv7.S -o obj/third_party/boringssl/boringssl_asm/vpaes-armv7.o
{standard input}: Assembler messages:
{standard input}: Error: .size expression for _vpaes_decrypt_consts does not evaluate to a constant
[1694/2719] CXX obj/third_party/boringssl/boringssl/tls_record.o
ninja: build stopped: subcommand failed.
```
#### fix: [https://boringssl-review.googlesource.com/c/boringssl/+/37824/4/crypto/fipsmodule/aes/asm/vpaes-armv7.pl]
В файле third_party/boringssl/src/crypto/fipsmodule/vpaes-armv7.pl после строк 
.type	_vpaes_decrypt_consts,%object
.align	4

добавляем строку
_vpaes_decrypt_consts:

Делаем тоже самое в файле third_party/boringssl/linux-arm/crypto/fipsmodule/vpaes-armv7.S
Это нужно для того, чтобы сразу продолжить компиляцию, не перегенерируя ASM файлы.

### error:
```
[1245/2232] CXX obj/webrtc/base/rtc_task_queue/sequenced_task_checker_impl.o
FAILED: obj/webrtc/base/rtc_task_queue/sequenced_task_checker_impl.o 
g++ -MMD -MF obj/webrtc/base/rtc_task_queue/sequenced_task_checker_impl.o.d -DV8_DEPRECATION_WARNINGS -DUSE_UDEV -DUSE_AURA=1 -DUSE_PANGO=1 -DUSE_CAIRO=1 -DUSE_GLIB=1 -DUSE_NSS_CERTS=1 -DUSE_X11=1 -DFULL_SAFE_BROWSING -DSAFE_BROWSING_CSD -DSAFE_BROWSING_DB_LOCAL -DCHROMIUM_BUILD -DENABLE_MEDIA_ROUTER=1 -DFIELDTRIAL_TESTING_ENABLED -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D_FORTIFY_SOURCE=2 -DNDEBUG -DNVALGRIND -DDYNAMIC_ANNOTATIONS_ENABLED=0 -DWEBRTC_ENABLE_PROTOBUF=0 -DWEBRTC_INCLUDE_INTERNAL_AUDIO_DEVICE -DEXPAT_RELATIVE_PATH -DHAVE_SCTP -DWEBRTC_ARCH_ARM -DWEBRTC_ARCH_ARM_V7 -DWEBRTC_HAS_NEON -DWEBRTC_POSIX -DWEBRTC_LINUX -I../.. -Igen -fno-strict-aliasing --param=ssp-buffer-size=4 -fstack-protector -Wno-builtin-macro-redefined -D__DATE__= -D__TIME__= -D__TIMESTAMP__= -funwind-tables -fPIC -pipe -march=armv7-a -mfloat-abi=hard -mtune=generic-armv7-a -pthread -mfpu=neon -mthumb -Wall -Wno-psabi -Wno-unused-local-typedefs -Wno-maybe-uninitialized -Wno-missing-field-initializers -Wno-unused-parameter -O2 -fno-ident -fdata-sections -ffunction-sections -fomit-frame-pointer -g2 -fvisibility=hidden -Wextra -Wno-unused-parameter -Wno-missing-field-initializers -Wno-strict-overflow -fvisibility-inlines-hidden -std=gnu++11 -Wno-narrowing -fno-rtti -fno-exceptions -Wnon-virtual-dtor -Woverloaded-virtual -c ../../webrtc/base/sequenced_task_checker_impl.cc -o obj/webrtc/base/rtc_task_queue/sequenced_task_checker_impl.o
In file included from ../../webrtc/base/sequenced_task_checker_impl.cc:19:0:
../../webrtc/base/task_queue.h:298:2: error: #error not supported.
 #error not supported.
  ^
[1247/2232] CXX obj/webrtc/base/rtc_base_approved/logging.o
```
#### fix:
самый идиотский способ - добавить в начало файла src/webrtc/base/task_queue.h строку:
#define WEBRTC_BUILD_LIBEVENT

по хорошему нужно найти, как заставить появиться это определение через BUILD.gn

### error:
```
[230/908] CXX obj/webrtc/examples/peerconnection_client/main_wnd.o
FAILED: obj/webrtc/examples/peerconnection_client/main_wnd.o 
g++ -MMD -MF obj/webrtc/examples/peerconnection_client/main_wnd.o.d -DV8_DEPRECATION_WARNINGS -DUSE_UDEV -DUSE_AURA=1 -DUSE_PANGO=1 -DUSE_CAIRO=1 -DUSE_GLIB=1 -DUSE_NSS_CERTS=1 -DUSE_X11=1 -DFULL_SAFE_BROWSING -DSAFE_BROWSING_CSD -DSAFE_BROWSING_DB_LOCAL -DCHROMIUM_BUILD -DENABLE_MEDIA_ROUTER=1 -DFIELDTRIAL_TESTING_ENABLED -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D_FORTIFY_SOURCE=2 -DNDEBUG -DNVALGRIND -DDYNAMIC_ANNOTATIONS_ENABLED=0 -DWEBRTC_ENABLE_PROTOBUF=0 -DWEBRTC_INCLUDE_INTERNAL_AUDIO_DEVICE -DEXPAT_RELATIVE_PATH -DHAVE_SCTP -DWEBRTC_ARCH_ARM -DWEBRTC_ARCH_ARM_V7 -DWEBRTC_HAS_NEON -DWEBRTC_POSIX -DWEBRTC_LINUX -DHAVE_WEBRTC_VIDEO -DHAVE_WEBRTC_VOICE -I../.. -Igen -I/usr/include/gtk-2.0 -I/usr/lib/x86_64-linux-gnu/gtk-2.0/include -I/usr/include/gio-unix-2.0 -I/usr/include/cairo -I/usr/include/pango-1.0 -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/pixman-1 -I/usr/include/libpng12 -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/libpng12 -I/usr/include/pango-1.0 -I/usr/include/harfbuzz -I/usr/include/pango-1.0 -I/usr/include/freetype2 -I/usr/include/glib-2.0 -I/usr/lib/x86_64-linux-gnu/glib-2.0/include -I../../third_party/libyuv/include -I../../third_party/jsoncpp/overrides/include -I../../third_party/jsoncpp/source/include -Wno-deprecated-declarations -fno-strict-aliasing --param=ssp-buffer-size=4 -fstack-protector -Wno-builtin-macro-redefined -D__DATE__= -D__TIME__= -D__TIMESTAMP__= -funwind-tables -fPIC -pipe -march=armv7-a -mfloat-abi=hard -mtune=generic-armv7-a -pthread -mfpu=neon -mthumb -Wall -Wno-psabi -Wno-unused-local-typedefs -Wno-maybe-uninitialized -Wno-missing-field-initializers -Wno-unused-parameter -O2 -fno-ident -fdata-sections -ffunction-sections -fomit-frame-pointer -g2 -fvisibility=hidden -Wextra -Wno-unused-parameter -Wno-missing-field-initializers -Wno-strict-overflow -fvisibility-inlines-hidden -std=gnu++11 -Wno-narrowing -fno-rtti -fno-exceptions -Wnon-virtual-dtor -Woverloaded-virtual -c ../../webrtc/examples/peerconnection/client/linux/main_wnd.cc -o obj/webrtc/examples/peerconnection_client/main_wnd.o
../../webrtc/examples/peerconnection/client/linux/main_wnd.cc:13:28: fatal error: gdk/gdkkeysyms.h: No such file or directory
 #include <gdk/gdkkeysyms.h>
                            ^
compilation terminated.
[232/908] CXX obj/webrtc/examples/peerconnection_client/peer_connection_client.o
```

#### fix:
???

# 3. Собираем SDK
```bash
mkdir -p ../libwebrtc/include
mkdir -p ../libwebrtc/lib
```

## 3.1. Копируем заголовочные файлы
```bash
find . -name '*.h' -exec cp --parents {} ../libwebrtc/include \;
```

## 3.2. Удаляем каталоги с не нужными заголовочными фалами
```bash
rm -Rf ../libwebrtc/include/build ../libwebrtc/include/buildtools ../libwebrtc/include/out ../libwebrtc/include/test ../libwebrtc/include/testing ../libwebrtc/include/tools_webrtc ../libwebrtc/include/examples
```

## 3.3. Копируем файлы библиотек
```bash
cp out/Release/obj/libwebrtc.a ../libwebrtc/lib
```