#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

mkdir -p $base/models

num_threads=6
model_name=model_wmt17
devices=-4

##################################

OMP_NUM_THREADS=$num_threads python -m sockeye.train \
			-s $base/data/train.bpe.de \
			-t $base/data/train.bpe.en \
			-vs $base/data/dev.bpe.de \
            -vt $base/data/dev.bpe.en \
            --batch-type=word \
            --batch-size=4096 \
            --max-seq-len=80:80 \
            --encoder rnn \
            --decoder rnn \
            --num-embed 256 \
			--num-layers 4:4 \
            --rnn-num-hidden 512 \
            --rnn-attention-type mlp \
            --embed-dropout=0.1:0.1 \
            --rnn-decoder-hidden-dropout=0.2 \
            --layer-normalization \
            --weight-tying \
            --weight-tying-type=src_trg \
            --label-smoothing 0.1 \
            --decode-and-evaluate 500 \
            --checkpoint-frequency=4000 \
            --max-num-checkpoint-not-improved=32 \
            --learning-rate-reduce-factor=0.7 \
            --initial-learning-rate=0.0002 \
            --learning-rate-reduce-num-not-improved=8 \
            --learning-rate-scheduler-type=plateau-reduce \
            --min-num-epochs=0 \
            --device-ids=$devices \
            --decode-and-evaluate-use-cpu \
            -o $base/models/$model_name
