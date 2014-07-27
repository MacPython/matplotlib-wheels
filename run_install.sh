source terryfy/travis_tools.sh
source terryfy/library_installers.sh

# Package versions for fresh source builds
FT_VERSION=2.5.3
PNG_VERSION=1.6.12
ZLIB_VERSION=1.2.8

TCL_URL=http://downloads.activestate.com/ActiveTcl/releases
TCL_VERSION=8.5.15.0
TCL_DMG=ActiveTcl8.5.15.1.297588-macosx10.5-i386-x86_64-threaded.dmg


function install_activestate_tcl {
    check_var $TCL_URL
    check_var $TCL_VERSION
    check_var $TCL_DMG
    local dmg_path=$DOWNLOADS_SDIR/$TCL_DMG
    curl $TCL_URL/$TCL_VERSION/$TCL_DMG > $dmg_path
    require_success "Failed to download tcl/tk"
    hdiutil attach $dmg_path -mountpoint /Volumes/Tcl
    sudo installer -pkg /Volumes/Tcl/ActiveTcl-8.5.pkg -target /
    require_success "Failed to install tcl/tk"
    hdiutil unmount /Volumes/Tcl
}

# Need pkg-config for freetype to find libpng
brew install pkg-config
# Set up build
clean_builds
clean_submodule matplotlib
# Need zlib for compatibility with new libpng on OSX 10.6
standard_install zlib $ZLIB_VERSION .tar.xz
standard_install libpng $PNG_VERSION
standard_install freetype $FT_VERSION .tar.gz freetype- "--with-harfbuzz=no"
# Need activestate tcl for compatibility with macpython osx install
# instructions
install_activestate_tcl
