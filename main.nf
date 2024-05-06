#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Process to convert data
process samestr_convert {
    publishDir "${params.output_directory}", mode: 'copy', overwrite: true

    input:
        path "inputs/"
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
        path "out_align/"
        path "samestr_db"

    output:
        path "out_summarize/*"

    script:
    template "summarize.sh"
}

workflow {
    if (!params.mpn_profiles) {error "Must specify --${mpn_profiles}"}
    if (!params.db) {error "Must specify --${db}"}
    if (!params.output_directory) {error "Must specify --${output_directory}"}

    mpn_profiles = Channel.fromPath(
        "${params.mpn_profiles}".split(',').toList()
    )
    db = file("${params.db}", type: 'dir')

    samestr_convert(mpn_profiles, db)

    samestr_merge(samestr_convert.out, db)

    samestr_filter(samestr_merge.out, db)

    samestr_stats(samestr_filter.out, db)

    samestr_compare(samestr_filter.out, db)

    samestr_summarize(samestr_compare.out, mpn_profiles, db)
}