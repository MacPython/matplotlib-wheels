# Travis install
# source this script to run the install on travis OSX workers

# Get needed utilities
source terryfy/travis_tools.sh

# Package versions for fresh source builds
FT_VERSION=2.5.3
PNG_VERSION=1.6.12
ZLIB_VERSION=1.2.8


# Compiler defaults
SYS_CC=clang
SYS_CXX=clang++
ARCH_FLAGS="-arch i386 -arch x86_64"
MACOSX_DEPLOYMENT_TARGET='10.6'


function check_version {
    if [ -z "$version" ]; then
        echo "Need version"
        exit 1
    fi
}


function check_var {
    if [ -z "$1" ]; then
        echo "Undefined required variable"
        exit 1
    fi
}


function init_vars {
    SRC_PREFIX=$PWD/working
    BUILD_PREFIX=$PWD/build
    export PATH=$BUILD_PREFIX/bin:$PATH
    export CPATH=$BUILD_PREFIX/include
    export LIBRARY_PATH=$BUILD_PREFIX/lib
    export PKG_CONFIG_PATH=$BUILD_PREFIX/lib/pkgconfig
}


function clean_builds {
    check_var $SRC_PREFIX
    check_var $BUILD_PREFIX
    rm -rf $SRC_PREFIX
    mkdir $SRC_PREFIX
    rm -rf $BUILD_PREFIX
    mkdir $BUILD_PREFIX
}


function install_zlib {
    check_var $ZLIB_VERSION
    check_var $SRC_PREFIX
    check_var $BUILD_PREFIX
    local archive_path="archives/zlib-${ZLIB_VERSION}.tar.xz"
    tar xvf $archive_path -C $SRC_PREFIX
    cd $SRC_PREFIX/zlib-$ZLIB_VERSION
    require_success "Failed to cd to zlib directory"
    CC=${SYS_CC} CXX=${SYS_CXX} CFLAGS=$ARCH_FLAGS ./configure --prefix=$BUILD_PREFIX
    make
    make install
    require_success "Failed to install zlib $version"
    cd ../..
}


function install_libpng {
    check_var $PNG_VERSION
    check_var $SRC_PREFIX
    check_var $BUILD_PREFIX
    local archive_path="archives/libpng-${PNG_VERSION}.tar.gz"
    tar zxvf $archive_path -C $SRC_PREFIX
    cd $SRC_PREFIX/libpng-$PNG_VERSION
    require_success "Failed to cd to png directory"
    CC=${SYS_CC} CXX=${SYS_CXX} CFLAGS=$ARCH_FLAGS ./configure --prefix=$BUILD_PREFIX
    make
    make install
    require_success "Failed to install png $version"
    cd ../..
}


function install_freetype {
    check_var $FT_VERSION
    check_var $SRC_PREFIX
    check_var $BUILD_PREFIX
    local archive_path="archives/freetype-${FT_VERSION}.tar.gz"
    tar zxvf $archive_path -C $SRC_PREFIX
    cd $SRC_PREFIX/freetype-$FT_VERSION
    require_success "Failed to cd to freetype directory"
    # harfbuzz is hard to build
    CC=${SYS_CC} CXX=${SYS_CXX} CFLAGS=$ARCH_FLAGS ./configure \
        --prefix=$BUILD_PREFIX --with-harfbuzz=no
    make
    make install
    require_success "Failed to install freetype $version"
    cd ../..
}
