#!/usr/bin/env python
""" Check we have expected tcl / tk version

We should pick up activestate not OSX tcl / tk
"""
from __future__ import print_function

import os
import sys

from subprocess import check_output

import matplotlib.backends._tkagg as tka

tcl_root = "/Library/Frameworks/Tcl.framework/Versions"
tcl_version = os.environ.get("TCL_VERSION")
if tcl_version is None:
    raise RuntimeError('Need defined TCL_VERSION env var')
tcl_2 = '.'.join(tcl_version.split('.')[:2])
tcl_3 = '.'.join(tcl_version.split('.')[:3])

tcl_path = '{0}/{1}/Tcl'.format(tcl_root, tcl_2)
required_line = ('{0} (compatibility version {1}.0, '
                 'current version {2})'.format(tcl_path, tcl_2, tcl_3))

install_names = check_output(['otool', '-L', tka.__file__])
print("Install names are:\n", install_names)
sys.exit(required_line.encode('ascii') not in install_names)
