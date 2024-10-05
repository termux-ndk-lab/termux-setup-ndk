#!/data/data/com.termux/files/usr/bin/bash
echo '================ cantrol architecture and android version ==================='
case $(uname -m) in
    aarch64)   echo 'aarch64 is allow, continue' ;;
    arm)  dpkg --print-architecture | grep -q "arm64" && \
          echo ' aarch64 is allow, continue' || \
          echo 'unfortunately arm is not allow, only suported is aarch64  it must exist' && exit 1  ;;
    *) echo 'unfortunately not allow, only suported is aarch64 it must exist' && exit 1   ;;
esac
s_version=$(termux-info | grep -A1 "Android version" | grep -Po "\\d+")
version=$(($s_version+0))
if (( $version < 9 )) then
	echo 'unfortunately anroid must be 9 or above'
	exit 1
fi
full=1;sdk=0;
while true; do
    read -p "Full ndk contain all headers and resources and light version contain only header which are nesessery for library fyne to build apk or arm. \n Do you wish to install full NDK? (y/n): " yn
    case $yn in
        [Yy]* ) full=1; break;;
        [Nn]* ) full=0; break;;
        * ) echo "Please answer y(yes) or n(no).";;
    esac
done

while true; do
    read -p "Do you wish to install SDK? It is for re-compile java for beginer useless (y/n): " yn
    case $yn in
        [Yy]* ) sdk=1; break;;
        [Nn]* ) sdk=0; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo '================================================================'
echo '                     install dependencies'
echo '================================================================'
pkg update && pkg upgrade && pkg install aapt apksigner dx ecj openjdk-17 git wget

if [ $sdk == 1 ]; then
  echo '================================================================'
  echo '                     download sdk.zip'
  echo '================================================================'
  cd ~ && wget https://github.com/Lzhiyong/termux-ndk/releases/download/android-sdk/android-sdk-aarch64.zip
  echo '================================================================'
  echo '                               unzip sdk.zip'
  echo '================================================================'
  cd ~ && unzip -qq android-sdk-aarch64.zip
  echo '================================================================'
  echo '                              tidy sdk.zip'
  echo '================================================================'
  cd ~ && rm android-sdk-aarch64.zip
fi
echo '================================================================'
echo '                     download ndk.zip'
echo '================================================================'
if [ $full == 1 ]; then 
  cd ~ && wget https://github.com/Lzhiyong/termux-ndk/releases/download/ndk-r23/android-ndk-r23c-aarch64.zip
else
  cd ~ && wget https://github.com/MatejMagat305/termux-ndk/releases/download/release/android-ndk-r23c-aarch64.zip
fi
echo '================================================================'
echo '                               unzip ndk.zip'
echo '================================================================'
cd ~ && unzip -qq android-ndk-r23c-aarch64.zip
echo '================================================================'
echo '                               fix sh in ndk path'
echo '================================================================'
cd ~ && termux-fix-shebang /data/data/com.termux/files/home/android-ndk-r23c/toolchains/llvm/prebuilt/linux-aarch64/bin/*
echo '================================================================'
echo '                               tidy ndk.zip'
echo '================================================================'
cd ~ && rm android-ndk-r23c-aarch64.zip


echo '================================================================'
echo '                               set env variables'
echo '================================================================'
if [ $sdk == 1 ]; then 
  echo 'export ANDROID_HOME=/data/data/com.termux/files/home/android-sdk/' >> ~/../usr/etc/profile
fi
echo 'export ANDROID_NDK_HOME=/data/data/com.termux/files/home/android-ndk-r23c/' >> ~/../usr/etc/profile
echo 'export ANDROID_NDK_ROOT=$ANDROID_NDK_HOME' >> ~/../usr/etc/profile

echo 'put "source ~/../usr/etc/profile"'
