#!/usr/bin/env bash 
if [ -d "$HOME/deps" ]
then
    echo building skia dependency...
    cd $HOME/deps
else
    echo directory does not exist... creating build dependencies
    mkdir $HOME/deps
    cd $HOME/deps
fi

#in $HOME/deps building skia
echo checking if skia installed correctly, else will install and build
if [ -d "$HOME/deps/skia" -a -d "$HOME/deps/depot_tools" ]
then
    echo SKIA files already exist... skipping
else #need to compile skia for 10.9
    echo downloading and compiling skia
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
    git clone -b aseprite-m71 https://github.com/aseprite/skia.git
    export PATH="${PWD}/depot_tools:${PATH}"
    cd skia
    python tools/git-sync-deps
    gn gen out/Release --args="is_official_build=true skia_use_system_expat=false skia_use_system_icu=false skia_use_libjpeg_turbo=false skia_use_system_libpng=false skia_use_system_libwebp=false skia_use_system_zlib=false extra_cflags_cc=[\"-frtti\"]"
    ninja -C out/Release skia
fi
unset MACOSX_DEPLOYMENT_TARGET
#download aseprite phase
cd $HOME/Desktop && mkdir -p aseprite/build && cd $HOME/Desktop/aseprite
if [ -d "aseprite" ]
then #updating pre existing source
    echo source already exists attempting to udpate it...
    cd $HOME/Desktop/aseprite/aseprite
    git pull && git submodule update --init --recursive
    mkdir -p build #creating build to store files generated from compilation
else #downloading non pre existing source
    echo could not find pre existing source... attempting to dowload...
    git clone --recursive https://github.com/aseprite/aseprite.git
    cd $HOME/Desktop/aseprite/aseprite && mkdir -p build
fi

#build aseprite phase
cd $HOME/Desktop/aseprite/aseprite/build
echo build start...
#initiate build
cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_OSX_ARCHITECTURES=x86_64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 \
  -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.14.sdk \
  -DLAF_OS_BACKEND=skia \
  -DSKIA_DIR=$HOME/deps/skia \
  -DSKIA_OUT_DIR=$HOME/deps/skia/out/Release \
  -G Ninja \
  ..
ninja aseprite
