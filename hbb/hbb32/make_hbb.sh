#!/bin/bash
script="$(readlink -f "$0")"
dir="$(dirname "$script")"

echo "docker build --network=host -t hbb32 $dir"
docker build --network=host -t hbb32 $dir
