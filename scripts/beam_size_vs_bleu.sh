#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

data=$base/data
configs=$base/configs

translations=$base/translations

mkdir -p $translations

src=de
trg=it

# cloned from https://github.com/bricksdont/moses-scripts
MOSES=$base/tools/moses-scripts/scripts

num_threads=4
device=4

# measure time

SECONDS=0

model_name=bpe_2k

echo "model_name $model_name"

config=$configs/$model_name.yaml

for beam_size in {1..10}; do
    cat $config | sed "s/beam_size: 10/beam_size: $beam_size/g" > $model_name.$beam_size.yaml


    echo "###############################################################################"
    echo "beam_size $beam_size"

    translations_sub=$translations/$model_name.$beam_size

    mkdir -p $translations_sub

    CUDA_VISIBLE_DEVICES=$device OMP_NUM_THREADS=$num_threads python -m joeynmt translate $model_name.$beam_size.yaml < $data/test.bpe1.$src > $translations_sub/test.bpe.$model_name.$trg

    # undo BPE (this does not do anything: https://github.com/joeynmt/joeynmt/issues/91)

    cat $translations_sub/test.bpe.$model_name.$trg | sed 's/\@\@ //g' > $translations_sub/test.tokenized.$model_name.$trg

    # undo tokenization

    cat $translations_sub/test.tokenized.$model_name.$trg | $MOSES/tokenizer/detokenizer.perl -l $trg > $translations_sub/test.$model_name.$trg

    # compute case-sensitive BLEU on detokenized data

    cat $translations_sub/test.$model_name.$trg | sacrebleu $data/test.$trg

done
