source terryfy/travis_tools.sh
source library_installers.sh

# Need cmake for openjpeg
brew install cmake
# Need pkg-config for freetype to find libpng
brew install pkg-config
# Set up build
init_vars
clean_builds
# Need zlib for compatibility with new libpng on OSX 10.6
install_zlib
install_libpng
install_freetype
