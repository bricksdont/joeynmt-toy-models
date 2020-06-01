#! /usr/bin/python3

import argparse
import logging

from collections import Counter

UNK_STRING = "<unk>"

def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--source", type=str, help="Source lines input", required=True)
    parser.add_argument("--target", type=str, help="Target lines input", required=True)
    parser.add_argument("--vocab", type=str, help="Path to save output vocabulary", required=True)
    parser.add_argument("--threshold", type=int, help="Vocabulary size threshold per language", required=False,
                        default=100000)

    args = parser.parse_args()

    return args


def main():

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)
    logging.debug(args)

    with open(args.source, "r") as source_handle, open(args.target, "r") as target_handle:

        source_tokens = source_handle.read().replace("\n", " ").split(" ")
        target_tokens = target_handle.read().replace("\n", " ").split(" ")

        source_counter = Counter(source_tokens)
        target_counter = Counter(target_tokens)

        source_vocab = set([c[0] for c in source_counter.most_common(args.threshold)])
        target_vocab = set([c[0] for c in target_counter.most_common(args.threshold)])

    vocab = source_vocab | target_vocab

    with open(args.vocab, "w") as vocab_handle:
        for v in vocab:
            vocab_handle.write(v + "\n")


if __name__ == '__main__':
    main()
