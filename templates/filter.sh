#!/bin/bash
set -e

samestr filter \
    --input-files out_merge/*.npy \
    --input-names inputs/*.names.txt \
    --marker-dir samestr_db/ \
    --clade-min-samples ${params.clade_min_samples} \
    --marker-trunc-len ${params.marker_trunc_len} \
    --global-pos-min-n-vcov ${params.global_pos_min_n_vcov} \
    --sample-pos-min-n-vcov ${params.sample_pos_min_n_vcov} \
    --sample-var-min-f-vcov ${params.sample_var_min_f_vcov} \
    --samples-min-n-hcov ${params.samples_min_n_hcov} \
    --nprocs ${task.cpus} \
    --output-dir out_filter/
