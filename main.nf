#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Process to convert data
process convert {
    publishDir "${params.output_directory}", mode: 'copy', overwrite: true

    input:
        path "inputs/"
        path "samestr_db/"

    output:
        path "out_convert/*"

    script:
    """#!/bin/bash
set -e

samestr convert \
    --input-files inputs/*.sam.bz2 \ 
    --marker-dir samestr_db/ \
    --nprocs ${task.cpus} \
    --min-vcov ${params.min_vcov} \
    --output-dir out_convert/
    """
}

// Process to merge data
process merge {
    publishDir "${params.output_directory}", mode: 'copy', overwrite: true

    input:
        path "out_convert/"
        path "samestr_db/"

    output:
        path "out_merge/*"

    script:
    """#!/bin/bash
set -e

samestr merge \
    --input-files out_convert/*.npz \
    --marker-dir samestr_db/ \
    --nprocs ${task.cpus} \
    --output-dir out_merge/
    """
}

// Process to filter data
process filter {
    publishDir "${params.output_directory}", mode: 'copy', overwrite: true

    input:
        path "out_merge/"
        path "samestr_db/"

    output:
        path "out_filter/*"

    script:
    """#!/bin/bash
set -e

samestr filter \
    --input-files out_merge/*.npy \
    --input-names inputs/*.names.txt \
    --marker-dir samestr_db/ \
    --clade-min-n-hcov ${params.clade_min_n_hcov} \
    --clade-min-samples ${params.clade_min_samples} \
    --marker-trunc-len ${params.marker_trunc_len} \
    --global-pos-min-n-vcov ${params.global_pos_min_n_vcov} \
    --sample-pos-min-n-vcov ${params.sample_pos_min_n_vcov} \
    --sample-var-min-f-vcov ${params.sample_var_min_f_vcov} \
    --nprocs ${task.cpus} \
    --output-dir out_filter/
    """
}

// Process to calculate statistics
process stats {
    publishDir "${params.output_directory}", mode: 'copy', overwrite: true

    input:
        path "out_filter/"
        path "samestr_db/"

    output:
        path "out_stats/*"

    script:
    """#!/bin/bash
set -e

samestr stats \
    --input-files out_filter/*.npy \
    --input-names out_filter/*.names.txt \
    --marker-dir samestr_db/ \
    --nprocs ${task.cpus} \
    --output-dir out_stats/
    """
}

// Process to compare data
process compare {
    publishDir "${params.output_directory}", mode: 'copy', overwrite: true

    input:
        path "out_filter/"
        path "samestr_db/"

    output:
        path "out_compare/*"

    script:
    """#!/bin/bash
set -e

samestr compare \
    --input-files out_filter/*.npy \
    --input-names out_filter/*.names.txt \
    --marker-dir samestr_db/ \
    --nprocs ${task.cpus} \
    --output-dir out_compare/
    """
}

// Process to summarize data
process summarize {
    publishDir "${params.output_directory}", mode: 'copy', overwrite: true

    input:
        path "out_compare/"
        path "out_align/"
        path "samestr_db/"

    output:
        path "out_summarize/*"

    script:
    """#!/bin/bash
set -e

samestr summarize \
    --input-dir out_compare/ \
    --tax-profiles-dir out_align/ \
    --marker-dir samestr_db/ \
    --output-dir out_summarize/ \
    --aln-pair-min-overlap ${params.aln_pair_min_overlap} \
    --aln-pair-min-similarity ${params.aln_pair_min_similarity}
    """
}

workflow {
    if (!params.mpn_profiles) {error "Must specify --${mpn_profiles}"}
    if (!params.db) {error "Must specify --${db}"}
    if (!params.output_directory) {error "Must specify --${output_directory}"}

    mpn_profiles = Channel.fromPath(
        "${params.mpn_profiles}".split(',').toList()
    )
    db = path("${params.db}", type: 'dir')

    convert(mpn_profiles, db)

    merge(convert.out, db)

    filter(merge.out, db)

    stats(filter.out, db)

    compare(filter.out, db)

    summarize(compare.out, mpn_profiles, db)
}