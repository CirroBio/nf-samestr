#!/bin/bash
set -e

samestr summarize \
    --input-dir out_compare/ \
    --tax-profiles-dir out_align/ \
    --marker-dir samestr_db/ \
    --output-dir out_summarize/ \
    --aln-pair-min-overlap ${params.aln_pair_min_overlap} \
    --aln-pair-min-similarity ${params.aln_pair_min_similarity}
