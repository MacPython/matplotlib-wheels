# Functions for working with matplotlib build install test

function mpl_build_install {
    check_var $BUILD_PREFIX
    check_var $SYS_CC
    check_var $SYS_CXX
    check_var $PYTHON_EXE
    cd matplotlib
    mkdir build
    cd build
    wget https://downloads.sourceforge.net/project/freetype/freetype2/2.6.1/freetype-2.6.1.tar.gz
    tar -xf freetype-2.6.1.tar.gz
    cd ../
    cat << EOF > setup.cfg
[directories]
# 0verride the default basedir in setupext.py.
# This can be a single directory or a comma-delimited list of directories.
basedirlist = $BUILD_PREFIX, /usr
EOF
    CC=${SYS_CC} CXX=${SYS_CXX} python setup.py bdist_wheel
    require_success "Matplotlib build failed"
    delocate-listdeps dist/*.whl # lists library dependencies
    delocate-wheel dist/*.whl # copies library dependencies into wheel
    require_success "Wheel delocation failed"
    delocate-addplat --rm-orig -x 10_9 -x 10_10 dist/*.whl
    pip install dist/*.whl
    cd ..
}


function mpl_test {
    check_var $PYTHON_EXE
    check_var $PIP_CMD
    echo "python $PYTHON_EXE"
    echo "pip $PIP_CMD"

    mkdir tmp_for_test
    cd tmp_for_test
    echo "sanity checks"
    $PYTHON_EXE -c "import dateutil; print(dateutil.__version__)"
    $PYTHON_EXE -c "import sys; print('\n'.join(sys.path))"
    $PYTHON_EXE -c "import matplotlib; print(matplotlib.__file__)"
    $PYTHON_EXE -c "from matplotlib import font_manager"

    echo "testing matplotlib using 1 process"
    # Exclude known fail on Python 3.4
    # https://github.com/matplotlib/matplotlib/pull/2981
    $PYTHON_EXE ../matplotlib/tests.py -sv -e test_override_builtins --no-network
    require_success "Testing matplotlib returned non-zero status"
    cd ..
}
