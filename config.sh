# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    if [ -n "$IS_OSX" ]; then
        export CC=clang
        export CXX=clang++
        brew install pkg-config
    fi
    source multibuild/library_builders.sh
    build_jpeg
    build_libpng
    build_bzip2
    # Use local freetype for versions which support it
    if [[ "$BUILD_COMMIT" =~ v2\. ]]; then
        export MPLLOCALFREETYPE=1
    else
        build_freetype
    fi
}

function build_wheel {
    # Override common_utils build_wheel function to fix version error
    build_bdist_wheel $@
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    MPL_SRC_DIR=../matplotlib
    # Get test images
    MPL_INSTALL_DIR=$(dirname $(python -c 'import matplotlib; print(matplotlib.__file__)'))
    cp -r ${MPL_SRC_DIR}/lib/matplotlib/tests/baseline_images $MPL_INSTALL_DIR/tests

    echo "sanity checks"
    python -c "import dateutil; print(dateutil.__version__)"
    python -c "import sys; print('\n'.join(sys.path))"
    python -c "import matplotlib; print(matplotlib.__file__)"
    python -c "from matplotlib import font_manager"

    echo "testing matplotlib using 1 process"
    python $MPL_SRC_DIR/tests.py -sv

    echo "Check import of tcl / tk"
    MPLBACKEND="tkagg" python -c 'import matplotlib.pyplot as plt; print(plt.get_backend())'
}
