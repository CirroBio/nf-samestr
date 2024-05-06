#!/bin/bash
set -e

samestr convert \
    --input-files inputs_sam/*.sam.bz2 \
    --tax-profiles-dir inputs_mpl/ \
    --tax-profiles-extension "${params.tax_profiles_extension}" \
    --marker-dir samestr_db/ \
    --nprocs ${task.cpus} \
    --min-vcov ${params.min_vcov} \
    --output-dir out_convert/
