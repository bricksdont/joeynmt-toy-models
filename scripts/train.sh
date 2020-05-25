#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

models=$base/models
configs=$base/configs

mkdir -p $models

num_threads=4
device=5

# measure time

SECONDS=0

logs=$base/logs

mkdir -p $logs

mkdir -p $logs/rnn_wmt16_deen_tying
mkdir -p $logs/rnn_wmt16_factors_concatenate_deen_tying
mkdir -p $logs/rnn_wmt16_factors_add_deen_tying

mkdir -p $logs/rnn_wmt16_deen_notying
mkdir -p $logs/rnn_wmt16_factors_concatenate_deen_notying
mkdir -p $logs/rnn_wmt16_factors_add_deen_notying

CUDA_VISIBLE_DEVICES=1 OMP_NUM_THREADS=$num_threads python -m joeynmt train $configs/rnn_wmt16_deen_notying.yaml > $logs/rnn_wmt16_deen_notying/out 2> $logs/rnn_wmt16_deen_notying/err &

CUDA_VISIBLE_DEVICES=2 OMP_NUM_THREADS=$num_threads python -m joeynmt train $configs/rnn_wmt16_deen_tying.yaml > $logs/rnn_wmt16_deen_tying/out 2> $logs/rnn_wmt16_deen_tying/err &

# train factor models:

CUDA_VISIBLE_DEVICES=3 OMP_NUM_THREADS=$num_threads python -m joeynmt train $configs/rnn_wmt16_factors_concatenate_deen_notying.yaml > $logs/rnn_wmt16_factors_concatenate_deen_notying/out 2> $logs/rnn_wmt16_factors_concatenate_deen_notying/err &

CUDA_VISIBLE_DEVICES=4 OMP_NUM_THREADS=$num_threads python -m joeynmt train $configs/rnn_wmt16_factors_concatenate_deen_tying.yaml > $logs/rnn_wmt16_factors_concatenate_deen_tying/out 2> $logs/rnn_wmt16_factors_concatenate_deen_tying/err &

CUDA_VISIBLE_DEVICES=5 OMP_NUM_THREADS=$num_threads python -m joeynmt train $configs/rnn_wmt16_factors_add_deen_notying.yaml > $logs/rnn_wmt16_factors_add_deen_notying/out 2> $logs/rnn_wmt16_factors_add_deen_notying/err &

CUDA_VISIBLE_DEVICES=6 OMP_NUM_THREADS=$num_threads python -m joeynmt train $configs/rnn_wmt16_factors_add_deen_tying.yaml > $logs/rnn_wmt16_factors_add_deen_tying/out 2> $logs/rnn_wmt16_factors_add_deen_tying/err &

echo "time taken:"
echo "$SECONDS seconds"
