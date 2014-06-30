# Functions for working with matplotlib build install test

function mpl_build_install {
    check_var $BUILD_PREFIX
    cd matplotlib
    cat << EOF > setup.cfg
[directories]
# 0verride the default basedir in setupext.py.
# This can be a single directory or a comma-delimited list of directories.
basedirlist = $BUILD_PREFIX, /usr
EOF
    python setup.py bdist_wheel
    delocate-wheel dist/*.whl
    rename_wheels dist/*.whl
    pip install dist/*.whl
    cd ..
}


function mpl_test {
    check_var $PYTHON_EXE
    check_var $PIP_CMD
    echo "python $PYTHON_EXE"
    echo "pip $PIP_CMD"

    mkdir tmp_for_test
    echo "sanity checks"
    $PYTHON_EXE -c "import dateutil; print(dateutil.__version__)"
    $PYTHON_EXE -c "import sys; print('\n'.join(sys.path))"
    $PYTHON_EXE -c "import matplotlib; print(matplotlib.__file__)"
    $PYTHON_EXE -c "from matplotlib import font_manager"

    echo "testing matplotlib using 8 processess"
    $PYTHON_EXE ../matplotlib/tests.py -sv --processes=8 --process-timeout=300
    cd ..
}
