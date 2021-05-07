#!/bin/bash
script="$(readlink -f "$0")"
dir="$(dirname "$script")"
docker build --network=host -t hbb64 $dir
