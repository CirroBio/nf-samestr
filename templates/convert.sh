#!/bin/bash
set -e

samestr convert \
    --input-files inputs_sam/*.sam.bz2 \
    --tax_profiles_dir inputs_mpl/ \
    --tax_profiles_extension "${params.tax_profiles_extension}" \
    --marker-dir samestr_db/ \
    --nprocs ${task.cpus} \
    --min-vcov ${params.min_vcov} \
    --output-dir out_convert/
