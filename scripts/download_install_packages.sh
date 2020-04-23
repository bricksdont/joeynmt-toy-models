#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

tools=$base/tools
mkdir -p $tools

echo "Make sure this script is executed AFTER you have activated a virtualenv"

# install joeynmt

git clone https://github.com/bricksdont/joeynmt.git $tools/joeynmt

(cd $tools/joeynmt && git checkout dummy_att && pip install .)

# install Moses scripts for preprocessing

git clone https://github.com/bricksdont/moses-scripts $tools/moses-scripts
