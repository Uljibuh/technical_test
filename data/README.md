# Data

This directory contains the RNA-seq input data used in the analysis.

## Raw data

The original paired-end FASTQ files correspond to ENA experiment
`SRX114799` and runs:

- SRR396928
- SRR397000
- SRR397072
- SRR397144

The FASTQ files are not included in this repository because of their size.

Dataset metadata is available in:

`../metadata/SRX114799_metadata.tsv`

## OptiType input

The `optitype_input/` directory contains merged R1 and R2 FASTQ files
generated from the four sequencing runs:

- `SRX114799_R1.fastq.gz`
- `SRX114799_R2.fastq.gz`

These derived FASTQ files are also excluded from GitHub because they
can be regenerated from the original sequencing data.
