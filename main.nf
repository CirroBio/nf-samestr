#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Convert the metaphlan inputs into the format expected by samestr
process mpl_sanitize {

    input:
        path "inputs_mpl/"

    output:
        path "sanitized/*"

    script:
    template "mpl_sanitize.py"
}

// Process to convert data
process samestr_convert {
    publishDir "${params.output_directory}", mode: 'copy', overwrite: true

    input:
        path "inputs_sam/"
        path "inputs_mpl/"
        path "samestr_db"

    output:
        path "out_convert/*"

    script:
    template "convert.sh"
}

// Process to merge data
process samestr_merge {
    publishDir "${params.output_directory}", mode: 'copy', overwrite: true

    input:
        path "out_convert/"
        path "samestr_db"

    output:
        path "out_merge/*"

    script:
    template "merge.sh"
}

// Process to filter data
process samestr_filter {
    publishDir "${params.output_directory}", mode: 'copy', overwrite: true

    input:
        path "out_merge/"
        path "samestr_db"

    output:
        path "out_filter/*"

    script:
    template "filter.sh"
}

// Process to calculate statistics
process samestr_stats {
    publishDir "${params.output_directory}", mode: 'copy', overwrite: true

    input:
        path "out_filter/"
        path "samestr_db"

    output:
        path "out_stats/*"

    script:
    template "stats.sh"
}

// Process to compare data
process samestr_compare {
    publishDir "${params.output_directory}", mode: 'copy', overwrite: true

    input:
        path "out_filter/"
        path "samestr_db"

    output:
        path "out_compare/*"

    script:
    template "compare.sh"
}

// Process to summarize data
process samestr_summarize {
    publishDir "${params.output_directory}", mode: 'copy', overwrite: true

    input:
        path "out_compare/"
        path "inputs_mpl/"
        path "samestr_db"

    output:
        path "out_summarize/*"

    script:
    template "summarize.sh"
}

workflow {
    if (!params.inputs_sam) {error "Must specify --${inputs_sam}"}
    if (!params.inputs_mpl) {error "Must specify --${inputs_mpl}"}
    if (!params.db) {error "Must specify --${db}"}
    if (!params.output_directory) {error "Must specify --${output_directory}"}

    inputs_sam = Channel
        .fromPath(
            "${params.inputs_sam}".split(',').toList()
        )
        .ifEmpty {error "No files found in --${inputs_sam}"}
        .toSortedList()
    
    inputs_mpl = Channel
        .fromPath(
            "${params.inputs_mpl}".split(',').toList()
        )
        .ifEmpty {error "No files found in --${inputs_mpl}"}
        .toSortedList()

    db = file("${params.db}", type: 'dir', checkIfExists: true)

    mpl_sanitize(inputs_mpl)

    samestr_convert(inputs_sam, mpl_sanitize.out, db)

    samestr_merge(samestr_convert.out, db)

    samestr_filter(samestr_merge.out, db)

    samestr_stats(samestr_filter.out, db)

    samestr_compare(samestr_filter.out, db)

    samestr_summarize(samestr_compare.out, inputs_mpl, db)
}