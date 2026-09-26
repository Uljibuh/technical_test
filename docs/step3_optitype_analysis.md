## 1. Objective

The purpose of this analysis was to infer the **HLA class I genotype** of RNA-seq experiment **SRX114799** using OptiType.

OptiType predicts two alleles for each of the three major HLA class I genes:

- HLA-A
- HLA-B
- HLA-C

The expected final output is therefore:

```text
HLA-A: allele 1 / allele 2
HLA-B: allele 1 / allele 2
HLA-C: allele 1 / allele 2
```

This analysis is independent of the TRUST4 TCR-repertoire result. TRUST4 reconstructs rearranged TCR/BCR sequences, whereas OptiType infers inherited HLA 
class I alleles from HLA-derived sequencing reads.

---

## 2. Input RNA-seq Data

SRX114799 contains four paired-end sequencing runs:

```text
SRR396928
SRR397000
SRR397072
SRR397144
```

The original FASTQ files were:

```text
SRR396928_1.fastq.gz
SRR396928_2.fastq.gz
SRR397000_1.fastq.gz
SRR397000_2.fastq.gz
SRR397072_1.fastq.gz
SRR397072_2.fastq.gz
SRR397144_1.fastq.gz
SRR397144_2.fastq.gz
```

All four runs belong to the same experiment/sample/library.

Total input:

```text
3,511,391 paired-end fragments
7,022,782 individual reads
```

---

## 3. Environment

System:

```text
macOS
Apple Silicon
architecture: arm64
```

Initial environment checks:

```bash
python --version
conda --version
uname -m
```

Observed:

```text
Python 3.10.8
conda 22.11.1
arm64
```

---

## 4. OptiType Installation

The Bioconda channel was first checked:

```bash
conda search -c bioconda optitype
```

Available versions included:

```text
1.3.4
1.3.5
1.5.0
```

OptiType 1.5.0 was installed in a dedicated Conda environment:

```bash
time conda create -n optitype_env \
  -c conda-forge \
  -c bioconda \
  optitype=1.5.0 \
  -y
```

The environment was then activated:

```bash
conda activate optitype_env
```

Version check:

```bash
conda list optitype
```

Result:

```text
optitype  1.5.0  pyhdfd78af_1  bioconda
```

The installed Python package was confirmed with:

```bash
python -m pip show optitype
```

Result included:

```text
Name: optitype
Version: 1.5.0
```

---

## 5. CLI Entry-Point Troubleshooting

An initial check used the legacy executable name:

```bash
which OptiTypePipeline.py
OptiTypePipeline.py --help
```

This returned:

```text
OptiTypePipeline.py not found
zsh: command not found: OptiTypePipeline.py
```

OptiType 1.5.0 installs the executable under the modern command:

```text
optitype
```

This was confirmed with:

```bash
ls "$CONDA_PREFIX/bin" | grep -i opti
```

Result:

```text
optitype
```

The CLI was then checked using:

```bash
optitype --help
```

which successfully displayed:

```text
Commands:
  check-deps
  info
  init-config
  run
```

Therefore the installation was successful; only the executable name differed from older OptiType documentation.

---

## 6. Dependency Check

Before running the analysis, all required external dependencies were verified:

```bash
optitype check-deps
```

Result:

```text
[OK] RazerS3
[OK] YARA mapper
[OK] YARA indexer
[OK] GLPK
[OK] CBC
[N/A] CPLEX (optional, commercial solver)
[OK] Reference data

All required dependencies are available!
```

This confirmed that the environment was ready for HLA typing.

---

## 7. Input Preparation

OptiType accepts:

```text
one FASTQ for single-end input
two FASTQs for paired-end input
```

Because SRX114799 consists of four sequencing runs from the same sample, all R1 files were concatenated into one R1 FASTQ and all R2 files were concatenated 
into one R2 FASTQ.

A dedicated input folder was created:

```bash
mkdir -p data/optitype_input
```

Merged R1:

```bash
cat \
  data/SRR396928_1.fastq.gz \
  data/SRR397000_1.fastq.gz \
  data/SRR397072_1.fastq.gz \
  data/SRR397144_1.fastq.gz \
  > data/optitype_input/SRX114799_R1.fastq.gz
```

Merged R2:

```bash
cat \
  data/SRR396928_2.fastq.gz \
  data/SRR397000_2.fastq.gz \
  data/SRR397072_2.fastq.gz \
  data/SRR397144_2.fastq.gz \
  > data/optitype_input/SRX114799_R2.fastq.gz
```

This preserves pairing because the run order was kept identical between R1 and R2.

The merged files were:

```text
SRX114799_R1.fastq.gz  106 MB
SRX114799_R2.fastq.gz  106 MB
```

---

## 8. Merged FASTQ Validation

### 8.1 Gzip integrity

Both files were checked:

```bash
gzip -t data/optitype_input/SRX114799_R1.fastq.gz
gzip -t data/optitype_input/SRX114799_R2.fastq.gz
```

No output was returned, indicating that both gzip files passed the integrity test.

### 8.2 Line count

The merged FASTQ line counts were checked:

```bash
echo "R1 lines:"
gzcat data/optitype_input/SRX114799_R1.fastq.gz | wc -l

echo "R2 lines:"
gzcat data/optitype_input/SRX114799_R2.fastq.gz | wc -l
```

Results:

```text
R1 lines: 14,045,564
R2 lines: 14,045,564
```

Because each FASTQ read uses four lines:

```text
14,045,564 / 4 = 3,511,391 reads
```

Therefore the merged input contains:

```text
3,511,391 R1 reads
3,511,391 R2 reads
3,511,391 paired-end fragments
```

This exactly matches the expected total from the four original sequencing runs.

---

## 9. OptiType Run Command

The result directory was created:

```bash
mkdir -p results/optitype
```

The analysis was run using:

```bash
time optitype run \
  -i data/optitype_input/SRX114799_R1.fastq.gz \
  -i data/optitype_input/SRX114799_R2.fastq.gz \
  --rna \
  -o results/optitype \
  -p SRX114799 \
  --threads 4
```

Important options:

```text
-i        input FASTQ
--rna     specify RNA-seq input
-o        output directory
-p        output prefix
--threads mapping threads
```

Two `-i` arguments were used because the data are paired-end RNA-seq.

---

## 10. Runtime

The analysis completed successfully.

Measured runtime:

```text
17.51s user
2.47s system
95% CPU
20.847s total wall time
```

Therefore the OptiType analysis required approximately:

**20.8 seconds wall-clock time using 4 mapping threads.**

---

## 11. Runtime Warning

The run produced the warning:

```text
WARNING: Initializing ordered Set R with a fundamentally unordered data source
(type: set). This WILL potentially lead to nondeterministic behavior in Pyomo
```

The run did not fail.

OptiType completed normally and generated:

```text
SRX114799_result.tsv
SRX114799_coverage_plot.pdf
```

The warning was therefore treated as a Pyomo implementation warning rather than a fatal analysis error.

---

## 12. Primary OptiType Result

The terminal reported:

```text
HLA-A: A*24:02 (homozygous)
HLA-B: B*07:02, B*40:02
HLA-C: C*02:02, C*07:02

Reads: 35
Objective: 34.05
```

The saved result file was inspected using:

```bash
cat results/optitype/SRX114799_result.tsv
```

Result:

```text
    A1       A2       B1       B2       C1       C2       Reads   Objective
0   A*24:02  A*24:02  B*07:02  B*40:02  C*02:02  C*07:02  35.0    34.055
```

---

## 13. HLA Genotype Interpretation

The final inferred HLA class I genotype is:

```text
HLA-A: A*24:02 / A*24:02
HLA-B: B*07:02 / B*40:02
HLA-C: C*02:02 / C*07:02
```

### HLA-A

```text
A1 = A*24:02
A2 = A*24:02
```

Both inferred HLA-A alleles are the same.

Therefore:

```text
HLA-A*24:02 homozygous
```

### HLA-B

```text
B1 = B*07:02
B2 = B*40:02
```

The two HLA-B alleles differ.

Therefore:

```text
HLA-B heterozygous
```

### HLA-C

```text
C1 = C*02:02
C2 = C*07:02
```

The two HLA-C alleles differ.

Therefore:

```text
HLA-C heterozygous
```

The labels A1/A2, B1/B2, and C1/C2 represent the two inferred allele copies for each HLA locus. They are not six different HLA genes.

---

## 14. Meaning of `Reads`

OptiType reported:

```text
Reads = 35
```

This does **not** mean that only 35 reads were present in the RNA-seq dataset.

The input contained approximately 3.51 million paired-end fragments.

Instead, `Reads = 35` represents the small subset of HLA-informative sequencing reads retained for the HLA typing problem.

Conceptually:

```text
3.51 million RNA-seq fragments
        ↓
most reads originate from non-HLA transcripts
        ↓
reads are mapped against HLA reference alleles
        ↓
HLA-informative read evidence
        ↓
35 reads used in the OptiType typing solution
```

The low number indicates that HLA-informative coverage in this RNA-seq experiment was sparse.

Therefore, the genotype was successfully called, but the evidence should be interpreted with appropriate caution.

---

## 15. Meaning of `Objective`

OptiType reported:

```text
Objective = 34.055
```

OptiType evaluates combinations of HLA alleles using an integer linear programming optimization model.

The objective value is the optimization score of the selected allele combination.

Conceptually:

```text
many possible HLA-A/B/C allele combinations
        ↓
compare each combination with mapped HLA read evidence
        ↓
optimization
        ↓
best-scoring solution selected
```

The reported objective value:

```text
34.055
```

is **not**:

- a percentage
- an accuracy value
- a probability
- a direct confidence score

It is the score of the selected OptiType optimization solution.

---

## 16. Coverage Plot

The analysis generated:

```text
results/optitype/SRX114799_coverage_plot.pdf
```

The plot contains six panels, corresponding to the six selected HLA reference allele sequences.

The allele labels visible in the coverage plot were:

```text
A*24:02:01:01
A*24:02:07
B*07:02:01
B*40:02:01
C*02:02:01
C*07:02:01:01
```

The final TSV reports the allele calls at the two-field level:

```text
A*24:02
A*24:02
B*07:02
B*40:02
C*02:02
C*07:02
```

The longer labels in the plot represent more detailed reference allele sequence names within those broader two-field allele calls.

---

## 17. Coverage Plot Axes

### X-axis

The x-axis represents:

```text
position along the HLA reference allele sequence
```

For example:

```text
x = 100
```

means approximately nucleotide position 100 along that allele reference sequence.

### Y-axis

The y-axis represents:

```text
read coverage
```

That is, how many mapped reads overlap a given nucleotide position on the HLA reference.

A single sequencing read spans many nucleotide positions, so one read contributes coverage over an interval rather than at only one x-axis position.

Therefore, the coverage heights should not be summed and compared directly with `Reads = 35`.

---

## 18. Coverage Plot Colors

The coverage plot separates mapped-read evidence according to:

1. whether both paired-end mates provide usable paired support
2. whether the mapped sequence contains mismatches relative to the allele reference
3. whether the mapping is unique or ambiguous

The four major color classes are:

```text
green  = paired + no mismatch
red    = paired + mismatch
yellow = unpaired + no mismatch
blue   = unpaired + mismatch
```

### Paired support

The original paired-end fragment produces:

```text
R1 + R2
```

If both reads can be mapped consistently to the same HLA reference allele in a valid paired-end arrangement, the fragment provides paired support.

Example:

```text
HLA-B*07:02 reference
|--------------------------------------|
     R1 -------->         <-------- R2
```

### Unpaired support

If only one mate from the original R1/R2 pair provides usable evidence for the candidate HLA allele, the read can still contribute as unpaired evidence.

Example:

```text
R1 → usable HLA alignment
R2 → no usable paired alignment
```

This does not mean that neither read matched an HLA allele. It means only one mate provided usable evidence for that allele.

---

## 19. Mapping Support vs Mismatch

Two separate questions are represented in the plot.

### Question 1: Does the read support this HLA allele?

A read supports an HLA allele when it can be plausibly aligned to that allele reference under the mapper's alignment criteria.

A read does not need to match every base perfectly in order to support the allele.

### Question 2: Does the aligned read contain mismatched bases?

After a read is aligned, its nucleotide bases can be compared directly with the reference sequence.

Example with no mismatch:

```text
reference: ACTGACCT
read:      ACTGACCT
```

Example with a mismatch:

```text
reference: ACTGACCT
read:      ACTGTCCT
               ^
```

The second read can still support the allele because the overall alignment is strong, even though one nucleotide differs.

Therefore:

```text
support = read aligns plausibly to the candidate HLA allele
mismatch = one or more bases differ inside that alignment
```

These are related but distinct concepts.

---

## 20. Unique vs Ambiguous Mapping

The lighter/darker shades in the plot distinguish unique and ambiguous mappings.

Conceptually:

```text
unique mapping
→ read has a preferred placement/reference interpretation

ambiguous mapping
→ read can plausibly align to multiple very similar HLA allele sequences
```

Ambiguous mapping is expected in HLA typing because many HLA alleles are highly similar in sequence.

The coverage plot therefore visualizes both strong and ambiguous evidence used by the typing procedure.

---

## 21. Coverage Plot Interpretation

The coverage plot shows read support distributed across the selected HLA allele reference sequences.

Coverage is relatively sparse overall, which is consistent with:

```text
Reads = 35
```

The selected allele references nevertheless show mapped-read coverage across multiple regions.

The appropriate interpretation is:

> OptiType identified a complete HLA class I genotype from the RNA-seq data. The coverage plot demonstrates mapped sequencing-read support across the 
selected HLA allele reference sequences. However, the total HLA-informative read count was low (35 reads), so the genotype should be interpreted as a valid 
computational prediction supported by sparse RNA-seq evidence rather than as a deeply covered HLA-typing result.

The coverage plot is primarily a supporting/QC visualization.

The primary genotype result remains the TSV output.

---

## 22. Main Output Files

The OptiType result directory contained:

```text
SRX114799_result.tsv
SRX114799_coverage_plot.pdf
```

Observed sizes:

```text
SRX114799_result.tsv          97 B
SRX114799_coverage_plot.pdf  108 KB
```

The TSV is the primary HLA genotype output.

The PDF provides visual support and coverage quality information.

---

## 23. Final OptiType Result

Final HLA class I genotype:

```text
HLA-A: A*24:02 / A*24:02
HLA-B: B*07:02 / B*40:02
HLA-C: C*02:02 / C*07:02
```

Supporting values:

```text
HLA-informative reads: 35
Objective: 34.055
```

Summary:

> OptiType successfully inferred a complete HLA class I genotype from the SRX114799 bulk RNA-seq data. HLA-A was predicted as A*24:02 homozygous, HLA-B as 
B*07:02/B*40:02, and HLA-C as C*02:02/C*07:02. The call was based on 35 HLA-informative reads, indicating relatively sparse HLA coverage. The coverage plot 
showed mapped-read evidence across the predicted HLA reference alleles and was used as a supporting quality-control visualization.

---

## 24. Timing Summary

| Step | Time |
|---|---:|
| OptiType Conda installation | recorded during environment creation; exact value should be copied from terminal log if available |
| Dependency validation | seconds |
| FASTQ concatenation | seconds |
| FASTQ integrity/count validation | seconds |
| OptiType analysis | 20.847 s wall time |
| Result and coverage inspection | manual analysis |

---

## 25. Troubleshooting Summary

### Legacy executable name

Problem:

```text
OptiTypePipeline.py not found
```

Resolution:

OptiType 1.5.0 uses:

```bash
optitype
```

instead of the legacy executable name.

### Pyomo warning

Observed:

```text
WARNING: Initializing ordered Set R with a fundamentally unordered data source
```

The warning did not stop the analysis, and valid output files were generated.

### Multiple sequencing runs

OptiType accepts only one FASTQ for single-end or two FASTQs for paired-end input.

Because the four SRR runs came from the same sample/library, the R1 FASTQs were concatenated together and the R2 FASTQs were concatenated together before 
analysis.

The merged files were validated by gzip integrity testing and exact line-count comparison before use.
"""

