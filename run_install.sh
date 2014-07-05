source terryfy/travis_tools.sh
source terryfy/library_installers.sh

# Package versions for fresh source builds
FT_VERSION=2.5.3
PNG_VERSION=1.6.12
ZLIB_VERSION=1.2.8

# Need pkg-config for freetype to find libpng
brew install pkg-config
# Set up build
clean_builds
clean_submodule matplotlib
# Need zlib for compatibility with new libpng on OSX 10.6
standard_install zlib $ZLIB_VERSION .tar.xz
standard_install libpng $PNG_VERSION
standard_install freetype $FT_VERSION .tar.gz freetype- "--with-harfbuzz=no"
