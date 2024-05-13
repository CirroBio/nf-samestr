#!/usr/bin/env python3

import os
import pandas as pd
from pathlib import Path


def sanitize(input_file, output_file):
    header = (
        [
            line
            for line in open(input_file)
            if line.startswith("#")
        ]
        [-1]
        .strip()
        .split("\t")
    )

    df = pd.read_csv(input_file, sep="\t", comment="#", names=header)

    for option in [
        ['#clade', 'NCBI_tax_id', 'relative_abundance'],
        ['#clade_name', 'NCBI_tax_id', 'relative_abundance'],
        ['#clade_name', 'clade_taxid', 'relative_abundance']
    ]:
        if all([cname in header for cname in option]):
            (
                df
                .reindex(columns=option)
                .to_csv(output_file, sep="\t", index=False)
            )
            return

    raise ValueError(f"Could not find expected columns in {input_file}")


def main():
    Path("sanitized").mkdir(exist_ok=True)
    for file in Path("inputs_mpl").rglob("*${params.tax_profiles_extension}"):

        sanitize(
            file,
            Path("sanitized") / file.name
        )


if __name__ == "__main__":
    main()
