# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

# Commit where MPLLOCALFREETYPE introduced
LOCAL_FT_COMMIT=5ad9b15

# Test arguments
NPROC=2
PYTEST_ARGS="-ra --maxfail=1000 --timeout=300 --durations=25 -n $NPROC"

function pip_opts {
    # Define extra pip arguments

    # cryptography dropped 32 bit linux support. 
    # the `--prefer-binary` flag encourages pip to use the latest wheel 
    # that satisfies the requirements instead of the newest src
    echo "--prefer-binary"
}

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    if [ -n "$IS_OSX" ]; then
        export CC=clang
        export CXX=clang++
        install_pkg_config
        # See https://github.com/matplotlib/matplotlib/issues/10649
        export LDFLAGS="-headerpad_max_install_names"
        build_new_zlib
    fi
    build_jpeg
    build_libpng
    build_bzip2
    # Use local freetype for versions which support it
    local has_local=$(cd matplotlib && set +e; git merge-base --is-ancestor $LOCAL_FT_COMMIT HEAD && echo 1)
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

function run_tests {
    # Runs tests on installed distribution from an empty directory
    MPL_SRC_DIR=../matplotlib
    # Get test images
    MPL_INSTALL_DIR=$(dirname $(python -c 'import matplotlib; print(matplotlib.__file__)'))
    cp -r ${MPL_SRC_DIR}/lib/matplotlib/tests/baseline_images $MPL_INSTALL_DIR/tests

    if [ -z "$IS_OSX" ]; then
        # Need fc-list for tests
        apt-get install fontconfig
    fi

    echo "sanity checks"
    python -c "import dateutil; print(dateutil.__version__)"
    python -c "import sys; print('\n'.join(sys.path))"
    python -c "import matplotlib; print(matplotlib.__file__)"
    python -c "from matplotlib import font_manager"

    # Workaround for pytest-xdist flaky collection order
    # https://github.com/pytest-dev/pytest/issues/920
    # https://github.com/pytest-dev/pytest/issues/1075
    export PYTHONHASHSEED=$(python -c 'import random; print(random.randint(1, 4294967295))')
    echo PYTHONHASHSEED=$PYTHONHASHSEED

    echo "testing matplotlib using $NPROC process(es)"
    py.test $PYTEST_ARGS -m 'not network' $MPL_INSTALL_DIR $(dirname ${MPL_INSTALL_DIR})/mpl_toolkits

    echo "Check import of tcl / tk"
    MPLBACKEND="tkagg" python -c 'import matplotlib.pyplot as plt; print(plt.get_backend())'
}
