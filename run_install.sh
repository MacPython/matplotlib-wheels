source terryfy/travis_tools.sh
source terryfy/library_installers.sh

function install_activestate_tcl {
    check_var $TCL_URL
    check_var $TCL_VERSION
    check_var $TCL_DMG
    check_var $DOWNLOADS_SDIR
    mkdir -p $DOWNLOADS_SDIR
    local dmg_path=$DOWNLOADS_SDIR/$TCL_DMG
    curl $TCL_URL/$TCL_VERSION/$TCL_DMG > $dmg_path
    require_success "Failed to download tcl/tk"
    echo $dmg_path
    ls -al $dmg_path
    sudo hdiutil attach $dmg_path -mountpoint /Volumes/Tcl
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
check_var $ZLIB_VERSION
standard_install zlib $ZLIB_VERSION .tar.xz
check_var $PNG_VERSION
standard_install libpng $PNG_VERSION
check_var $FT_VERSION
standard_install freetype $FT_VERSION .tar.gz freetype- "--with-harfbuzz=no"
# Need activestate tcl for compatibility with macpython osx install
# instructions
install_activestate_tcl
