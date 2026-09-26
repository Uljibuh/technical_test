# Technical Test — RNA-seq Immune Receptor and HLA Analysis

## Overview

This project analyzes the human paired-end RNA-seq experiment **SRX114799** to recover immune-related information from bulk transcriptomic sequencing data.

The workflow includes:

1. RNA-seq data acquisition and validation
2. TCR/BCR reconstruction using **TRUST4**
3. HLA class I typing using **OptiType**

The experiment contains four sequencing runs:

- SRR396928
- SRR397000
- SRR397072
- SRR397144

Together they contain **3,511,391 paired-end fragments**.

---

## Project Structure

```text
technical_test/
├── README.md
├── data/
│   ├── SRR396928_1.fastq.gz
│   ├── SRR396928_2.fastq.gz
│   ├── SRR397000_1.fastq.gz
│   ├── SRR397000_2.fastq.gz
│   ├── SRR397072_1.fastq.gz
│   ├── SRR397072_2.fastq.gz
│   ├── SRR397144_1.fastq.gz
│   ├── SRR397144_2.fastq.gz
│   └── optitype_input/
├── docs/
│   ├── step1_data_acquisition.md
│   ├── step2_trust4_analysis.md
│   └── step3_optitype_analysis.md
├── logs/
├── metadata/
│   └── SRX114799_metadata.tsv
├── results/
│   ├── trust4/
│   └── optitype/
├── scripts/
│   └── 01_data_check.sh
└── software/
    └── TRUST4/
```

---

## Step 1 — Data Acquisition

RNA-seq FASTQ files were downloaded from the European Nucleotide Archive for experiment **SRX114799**.

All eight compressed FASTQ files passed gzip integrity checks, and R1/R2 read counts matched for all four sequencing runs.

Detailed documentation:

```text
docs/step1_data_acquisition.md
```

---

## Step 2 — TRUST4 Analysis

TRUST4 was compiled and run on the four paired-end sequencing runs together.

The analysis detected:

```text
10 TCR-associated assemblies
├── 6 TRA-associated
└── 4 TRB-associated
```

However, none of these assemblies contained a complete TCR CDR3 sequence.

Final TCR-specific results:

```text
TCR-associated assemblies: 10
TCR CDR3 records:          0
Final TRA/TRB clonotypes:  0
```

The data nevertheless contained adaptive immune-receptor signal, including reconstructed B-cell receptor sequences.

Detailed documentation:

```text
docs/step2_trust4_analysis.md
```

Main results:

```text
results/trust4/
```

---

## Step 3 — OptiType HLA Typing

The four sequencing runs were merged into one R1 and one R2 FASTQ file and analyzed using **OptiType 1.5.0** in RNA-seq mode.

The inferred HLA class I genotype was:

```text
HLA-A: A*24:02 / A*24:02
HLA-B: B*07:02 / B*40:02
HLA-C: C*02:02 / C*07:02
```

OptiType reported:

```text
HLA-informative reads: 35
Objective: 34.055
```

The HLA prediction was successfully generated, although the number of HLA-informative reads was relatively low.

Detailed documentation:

```text
docs/step3_optitype_analysis.md
```

Main results:

```text
results/optitype/SRX114799_result.tsv
results/optitype/SRX114799_coverage_plot.pdf
```

---

## Software

The analysis used:

- TRUST4 v1.1.11-r641
- OptiType 1.5.0
- Conda
- Python 3.10.8
- macOS on Apple Silicon (`arm64`)

TRUST4 was compiled from source.

---

## Notes

This dataset is general bulk RNA-seq rather than targeted TCR sequencing.

TRUST4 detected partial TCR-associated sequence evidence, but the available RNA-seq coverage was insufficient to reconstruct complete reportable TCR 
clonotypes.

OptiType successfully inferred a complete HLA class I genotype from the same RNA-seq experiment.

More detailed commands, validation steps, runtime measurements, troubleshooting, and result interpretation are provided in the files under `docs/`.
