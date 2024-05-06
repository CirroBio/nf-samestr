#!/bin/bash
set -e

samestr stats \
    --input-files out_filter/*.npy \
    --input-names out_filter/*.names.txt \
    --marker-dir samestr_db/ \
    --nprocs ${task.cpus} \
    --output-dir out_stats/
