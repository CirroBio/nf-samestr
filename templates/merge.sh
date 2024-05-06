#!/bin/bash
set -e

samestr merge \
    --input-files out_convert/*.npz \
    --marker-dir samestr_db/ \
    --nprocs ${task.cpus} \
    --output-dir out_merge/
