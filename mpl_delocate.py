#!/usr/bin/env python
""" Delocate matplotlib wheel, omitting tcl / tk

tcl / tk are from ActiveState, and they don't allow us to redistribute

Also, confirm binary is dual Intel arch
"""
from __future__ import print_function

import sys

from delocate import delocate_wheel


def my_filter(libname):
    for prefix in ('/usr/lib',
                   '/System',
                   '/Library/Frameworks/Tcl.framework',
                   '/Library/Frameworks/Tk.framework'):
        if libname.startswith(prefix):
            return False
    return True


for wheel in sys.argv[1:]:
    print('delocating', wheel)
    copied = delocate_wheel(wheel, wheel,
                            copy_filt_func = my_filter,
                            require_archs='intel',
                            check_verbose=True)
