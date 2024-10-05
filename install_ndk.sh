#!/data/data/com.termux/files/usr/bin/bash
#edited by gpt chat

# ================== Check architecture and Android version ==================
echo '================ Checking architecture and Android version =================='
ARCH=$(uname -m)
case $ARCH in
    aarch64)   
        echo 'Architecture aarch64 is supported, proceeding.' 
        ;;
    arm)  
        if dpkg --print-architecture | grep -q "arm64"; then
            echo 'Architecture aarch64 is supported, proceeding.'
        else
            echo 'Unfortunately, arm architecture is not supported. Only aarch64 is supported.'
            exit 1
        fi
        ;;
    *)  
        echo 'Unfortunately, this architecture is not supported. Only aarch64 is supported.'
        exit 1
        ;;
esac

# ================== Check Android version ==================
ANDROID_VERSION=$(termux-info | grep -A1 "Android version" | grep -Po "\\d+")
if (( ANDROID_VERSION < 9 )); then
    echo 'Unfortunately, Android version must be 9 or higher.'
    exit 1
fi

# ================== NDK selection ==================
FULL_NDK=1
while true; do
    read -p "Do you want to install the full version of NDK (includes all headers and resources) or the lightweight version (only necessary headers for Fyne to build)? (y/n): " yn
    case $yn in
        [Yy]* ) FULL_NDK=1; break;;
        [Nn]* ) FULL_NDK=0; break;;
        * ) echo "Please answer y (yes) or n (no).";;
    esac
done

# ================== SDK selection ==================
INSTALL_SDK=0
while true; do
    read -p "Do you want to install the SDK? (For recompiling Java, usually unnecessary for beginners) (y/n): " yn
    case $yn in
        [Yy]* ) INSTALL_SDK=1; break;;
        [Nn]* ) INSTALL_SDK=0; break;;
        * ) echo "Please answer y (yes) or n (no).";;
    esac
done

# ================== Installing dependencies ==================
echo '================================================================'
echo '                     Installing dependencies'
echo '================================================================'
pkg update && pkg upgrade -y && pkg install -y aapt apksigner dx ecj openjdk-17 git wget

# ================== SDK Installation ==================
if [ $INSTALL_SDK -eq 1 ]; then
    echo '================================================================'
    echo '                     Downloading SDK'
    echo '================================================================'
    cd ~ && wget https://github.com/Lzhiyong/termux-ndk/releases/download/android-sdk/android-sdk-aarch64.zip

    echo '================================================================'
    echo '                     Unzipping SDK'
    echo '================================================================'
    cd ~ && unzip -qq android-sdk-aarch64.zip && rm android-sdk-aarch64.zip
fi

# ================== NDK Installation ==================
echo '================================================================'
echo '                     Downloading NDK'
echo '================================================================'
if [ $FULL_NDK -eq 1 ]; then
    cd ~ && wget https://github.com/lzhiyong/termux-ndk/releases/download/android-ndk/android-ndk-r27b-aarch64.zip -o android-ndk-aarch64.zip
else
    cd ~ && wget https://github.com/MatejMagat305/termux-ndk/releases/download/release/android-ndk-r23c-aarch64.zip -o android-ndk-aarch64.zip
fi

echo '================================================================'
echo '                     Unzipping NDK'
echo '================================================================'
cd ~ && unzip -qq android-ndk-aarch64.zip && rm android-ndk-aarch64.zip

# ================== Fixing shebang in NDK path ==================
echo '================================================================'
echo '                     Fixing shebang in NDK tools'
echo '================================================================'
termux-fix-shebang ~/android-ndk/toolchains/llvm/prebuilt/linux-aarch64/bin/*

# ================== Setting environment variables ==================
echo '================================================================'
echo '                     Setting environment variables'
echo '================================================================'
if [ $INSTALL_SDK -eq 1 ]; then 
    echo 'export ANDROID_HOME=$HOME/android-sdk/' >> ~/.bashrc
fi
echo 'export ANDROID_NDK_HOME=$HOME/android-ndk-r27b/' >> ~/.bashrc
echo 'export ANDROID_NDK_ROOT=$ANDROID_NDK_HOME' >> ~/.bashrc

echo 'Run "source ~/.bashrc" to apply the changes.'
