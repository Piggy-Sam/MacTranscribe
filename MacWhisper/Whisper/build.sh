#!/bin/bash

set -e

cd "$(dirname "$0")"

rm -rf build # Aggressive clean

cmake . -B build -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0
cmake --build build -j

mkdir -p ../Libs
find build -name libwhisper.a -exec cp {} ../Libs \;
cp build/libwhisper_wrapper.a ../Libs