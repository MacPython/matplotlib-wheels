# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    if [ -n "$IS_OSX" ]; then
        export CC=clang
        export CXX=clang++
        brew install pkg-config
        # Problems on OSX 10.6 with zlib
        # https://github.com/matplotlib/matplotlib/issues/6945
        # Promote BUILD_PREFIX on search path to find new zlib
        # Check include path with ``clang -x c -v -E /dev/null``
        # Check lib path with ``ld -v .``
        # https://langui.sh/2015/07/24/osx-clang-include-lib-search-paths/
        export CPPFLAGS="-I$BUILD_PREFIX/include"
        export LDFLAGS="-L$BUILD_PREFIX/lib"
        build_new_zlib
    fi
    build_jpeg
    build_libpng
    build_bzip2
    # Use local freetype for versions which support it
    local has_local=$(cd matplotlib && set +e; git merge-base --is-ancestor 5ad9b15 HEAD && echo 1)
    if [ -n "$has_local" ]; then
        export MPLLOCALFREETYPE=1
    else
        build_freetype
    fi
    # Include tests to allow testing of installed package
    cat > matplotlib/setup.cfg << EOF
[packages]
tests = True
toolkits_tests = True
EOF
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

    # Patch testing function for recursion
    (cd $MPL_SRC_DIR && patch -p1 < ../recursion.patch)

    echo "testing matplotlib using 1 process"
    # 1.5.x has pesky unicode error for sphinx extension test
    local mpl_version=$(python -c "import matplotlib; print(matplotlib.__version__)")
    if [[ "$mpl_version" =~ 1\. ]]; then
        local extra_test_args="-e TestTinyPages"
    fi
    python $MPL_SRC_DIR/tests.py -sv $extra_test_args

    echo "Check import of tcl / tk"
    MPLBACKEND="tkagg" python -c 'import matplotlib.pyplot as plt; print(plt.get_backend())'
}
