#!/usr/bin/env python
""" Check we have expected tcl / tk version

We should pick up activestate not OSX tcl / tk
"""
from __future__ import print_function

import sys

from subprocess import check_output

import matplotlib.backends._tkagg as tka

required_line = b"/Library/Frameworks/Tcl.framework/Versions/8.5/Tcl (compatibility version 8.5.0, current version 8.5.15)"

install_names = check_output(['otool', '-L', tka.__file__])
print(install_names)
sys.exit(required_line not in install_names)
