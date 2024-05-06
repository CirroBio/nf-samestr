#!/bin/bash
set -e

samestr convert \
    --input-files inputs/*.sam.bz2 \ 
    --marker-dir samestr_db/ \
    --nprocs ${task.cpus} \
    --min-vcov ${params.min_vcov} \
    --output-dir out_convert/
