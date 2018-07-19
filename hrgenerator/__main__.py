# -*- coding: utf-8 -*-
"""
Script to run when running hrgenerator in command line.

@author: skasch
"""

import argparse

from .apl import APL

def hrgenerator_args(parser):
    """
    Add arguments to argparse parser
    """
    parser.add_argument('--profiles', '-p',
                        type=str,
                        nargs='+',
                        help='Location of the simc profile(s) to parse',
                        required=True)
    parser.add_argument('--exports', '-e',
                        type=str,
                        default=None,
                        nargs='+',
                        help=('Where to export the lua script. Must be of the '
                              'same length as --profiles if specified.'))


def change_ext(file_path, ext='lua'):
    """
    Changes the extension of a file to ext.
    """
    file_root = '.'.join(file_path.split('.')[:-1])
    return f'{file_root}.{ext}'


def main():
    """
    Function to process if HRGenerator is used as a script.
    """
    parser = argparse.ArgumentParser()
    hrgenerator_args(parser)
    args = parser.parse_args()
    try:
        assert args.exports is None or len(args.profiles) == len(args.exports)
    except AssertionError:
        raise ValueError(f'Inconsistant numbers of profiles '
                         f'({len(args.profiles)}) and exports '
                         f'({len(args.exports)}) arguments.')
    for i, arg_profile in enumerate(args.profiles):
        apl = APL()
        apl.read_profile(arg_profile)
        if args.exports is None:
            arg_export = change_ext(arg_profile)
        else:
            arg_export = args.exports[i]
        apl.export_lua(arg_export)


main()
