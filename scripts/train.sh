#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

models=$base/models
configs=$base/configs

mkdir -p $models

num_threads=4
device=4

# measure time

SECONDS=0

for model_name in bpe_2k bpe_4k; do

  if [[ -f $configs/$model_name.yaml ]]; then
      echo "config exists: $configs/$model_name.yaml"
      CUDA_VISIBLE_DEVICES=$device OMP_NUM_THREADS=$num_threads python -m joeynmt train $configs/$model_name.yaml
  fi
done

echo "time taken:"
echo "$SECONDS seconds"

