#!/usr/bin/env
""" Remove test images from matplotlib wheel(s)
"""
from __future__ import print_function

from os.path import join as pjoin, basename, abspath, isdir
from shutil import rmtree
from argparse import ArgumentParser

from subprocess import check_call, check_output

IMAGE_PATH = pjoin('matplotlib', 'tests', 'baseline_images')

from delocate.wheeltools import InWheelCtx


def get_needed(lib_fname):
    res = check_output(['patchelf', '--print-needed'] + [lib_fname])
    return [name.strip() for name in res.decode('latin1').splitlines()]


def rm_needed(lib_name, lib_fname):
    check_call(['patchelf', '--remove-needed', lib_name, lib_fname])


def rm_images(whl_fname, out_fname, verbose=False):
    whl_fname = abspath(whl_fname)
    out_fname = abspath(out_fname)
    with InWheelCtx(whl_fname) as ctx:
        if not isdir(IMAGE_PATH):
            if verbose:
                print('No {} in {}'.format(IMAGE_PATH, whl_fname))
            return
        rmtree(IMAGE_PATH)
        # Write the wheel
        ctx.out_wheel = out_fname


def get_parser():
    parser = ArgumentParser()
    parser.add_argument('whl_fnames', nargs='+')
    parser.add_argument('--verbose', action='store_true')
    parser.add_argument('--out-path')
    return parser


def main():
    args = get_parser().parse_args()
    for whl_fname in args.whl_fnames:
        out_fname = (pjoin(args.out_path, basename(whl_fname)) if args.out_path
                     else whl_fname)
        if args.verbose:
            print('Removing test images from {}'.format(whl_fname))
        rm_images(whl_fname, out_fname, verbose=args.verbose)


if __name__ == "__main__":
    main()
