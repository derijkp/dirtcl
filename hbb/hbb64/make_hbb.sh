#!/bin/bash
script="$(readlink -f "$0")"
dir="$(dirname "$script")"
docker build -t hbb64 $dir
