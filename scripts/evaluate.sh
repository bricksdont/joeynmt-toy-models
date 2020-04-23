#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

data=$base/data
configs=$base/configs

translations=$base/translations

mkdir -p $translations

src=en
trg=de

# cloned from https://github.com/bricksdont/moses-scripts
MOSES=$base/tools/moses-scripts/scripts

num_threads=6
device=5


for model_name in rnn_wmt17_ende rnn_attaverage_wmt17_ende rnn_attlast_wmt17_ende; do

    echo "###############################################################################"
    echo "model_name $model_name"

    CUDA_VISIBLE_DEVICES=$device OMP_NUM_THREADS=$num_threads python -m joeynmt translate $configs/$model_name.yaml < $data/test.bpe.$src > $translations/test.bpe.$model_name.$trg

    # undo BPE (this does not do anything: https://github.com/joeynmt/joeynmt/issues/91)

    cat $translations/test.bpe.$model_name.$trg | sed 's/\@\@ //g' > $translations/test.truecased.$model_name.$trg

    # undo truecasing

    cat $translations/test.truecased.$model_name.$trg | $MOSES/recaser/detruecase.perl > $translations/test.tokenized.$model_name.$trg

    # undo tokenization

    cat $translations/test.tokenized.$model_name.$trg | $MOSES/tokenizer/detokenizer.perl -l $trg > $translations/test.$model_name.$trg

    # compute case-sensitive BLEU on detokenized data

    cat $translations/test.$model_name.$trg | sacrebleu $data/test.$trg

done
