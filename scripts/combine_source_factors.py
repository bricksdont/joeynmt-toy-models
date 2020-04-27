#! /usr/bin/python3

import sys
import argparse
import logging


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--source", type=str, help="Source lines input", required=True)
    parser.add_argument("--factor", type=str, help="Factor lines input", required=True)
    parser.add_argument("--delimiter", type=str, help="Target lines input", required=False,
                        default=" ||| ")

    args = parser.parse_args()

    return args

def main():

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)
    logging.debug(args)

    with open(args.source, "r") as source_handle, open(args.factor, "r") as factor_handle:
        for source_line, factor_line in zip(source_handle, factor_handle):
            source_line = source_line.strip()
            factor_line = factor_line.strip()

            combined_line = args.delimiter.join([source_line, factor_line])
            print(combined_line)


if __name__ == '__main__':
    main()
