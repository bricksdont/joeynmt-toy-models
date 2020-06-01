#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

models=$base/models
configs=$base/configs
logs=$base/logs

mkdir -p $models
mkdir -p $logs

num_threads=4

for model_name in word_2k bpe_2k bpe_4k; do
    mkdir -p $logs/$model_name
done

CUDA_VISIBLE_DEVICES=1 OMP_NUM_THREADS=$num_threads python -m joeynmt train $configs/word_2k.yaml > $logs/word_2k/out 2> $logs/word_2k/err &

CUDA_VISIBLE_DEVICES=2 OMP_NUM_THREADS=$num_threads python -m joeynmt train $configs/bpe_2k.yaml > $logs/bpe_2k/out 2> $logs/bpe_2k/err &

CUDA_VISIBLE_DEVICES=3 OMP_NUM_THREADS=$num_threads python -m joeynmt train $configs/bpe_4k.yaml > $logs/bpe_4k/out 2> $logs/bpe_4k/err &
