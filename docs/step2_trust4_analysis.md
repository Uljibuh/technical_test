## 1. Objective

The purpose of this analysis was to use TRUST4 to recover T-cell receptor (TCR) and other adaptive immune receptor information from the RNA-seq experiment 
**SRX114799**.

SRX114799 is a human paired-end bulk RNA-seq experiment consisting of four sequencing runs:

- SRR396928
- SRR397000
- SRR397072
- SRR397144

All four runs belong to the same experiment, sample, and library, so they were analyzed together.

---

## 2. Input Data

The analysis used the following paired-end FASTQ files:

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

The four runs contained a total of:

- **3,511,391 paired-end fragments**
- **7,022,782 individual reads**

All FASTQ files passed gzip integrity checking, and the R1/R2 read counts matched within each sequencing run.

---

## 3. TRUST4 Installation

### 3.1 Prerequisite check

The system already had:

```bash
git --version
make --version
clang --version
```

The environment was:

- macOS
- Apple Silicon (`arm64`)
- Git available
- GNU Make available
- Apple Clang available

### 3.2 Clone TRUST4

A software directory was created:

```bash
mkdir -p ~/technical_test/software
cd ~/technical_test/software
```

TRUST4 was cloned from the official GitHub repository:

```bash
git clone https://github.com/liulab-dfci/TRUST4.git
```

Then:

```bash
cd ~/technical_test/software/TRUST4
```

The checked-out repository was on the `master` branch at commit:

```text
a3fedd4
```

### 3.3 Compile TRUST4

TRUST4 was compiled with:

```bash
time make
```

Compilation completed successfully.

Observed wall-clock time:

```text
17.549 seconds
```

The main executables were successfully generated:

```text
TRUST4
annotator
```

Running:

```bash
./TRUST4
```

displayed the TRUST4 usage information, confirming that the executable was functional.

The wrapper reported:

```text
TRUST4 v1.1.11-r641
```

---

## 4. Reference Files

The TRUST4 repository contained the required human immune-receptor references:

```text
hg38_bcrtcr.fa
human_IMGT+C.fa
```

The analysis used:

```text
-f hg38_bcrtcr.fa
--ref human_IMGT+C.fa
```

`hg38_bcrtcr.fa` was used for candidate receptor-read extraction, while `human_IMGT+C.fa` was used for detailed V/D/J/C annotation.

Because this dataset is ordinary transcriptomic bulk RNA-seq rather than targeted TCR-seq/BCR-seq, the `--repseq` option was **not** used.

---

## 5. TRUST4 Run Command

The four sequencing runs were analyzed together using wildcard input.

The exact command was:

```bash
cd ~/technical_test/software/TRUST4

time ./run-trust4 \
  -f hg38_bcrtcr.fa \
  --ref human_IMGT+C.fa \
  -1 ~/technical_test/data/*_1.fastq.gz \
  -2 ~/technical_test/data/*_2.fastq.gz \
  -o ~/technical_test/results/trust4/SRX114799 \
  -t 4
```

The shell expanded the R1 wildcard to:

```text
SRR396928_1.fastq.gz
SRR397000_1.fastq.gz
SRR397072_1.fastq.gz
SRR397144_1.fastq.gz
```

and the R2 wildcard to the corresponding:

```text
SRR396928_2.fastq.gz
SRR397000_2.fastq.gz
SRR397072_2.fastq.gz
SRR397144_2.fastq.gz
```

This preserved the paired-end structure while allowing all four runs from the same experiment to be processed together.

---

## 6. TRUST4 Runtime

The TRUST4 wrapper began at:

```text
Fri Sep 25 19:33:45 2026
```

and finished at:

```text
Fri Sep 25 19:34:29 2026
```

The measured runtime was:

```text
157.32s user
0.55s system
358% CPU
44.013s total wall time
```

Therefore, the pooled TRUST4 analysis required approximately:

**44 seconds wall-clock time using 4 threads.**

---

## 7. TRUST4 Processing Summary

The TRUST4 log showed the following major stages:

### 7.1 Candidate receptor-read extraction

TRUST4 first extracted reads potentially related to immune receptors.

Generated files:

```text
SRX114799_toassemble_1.fq
SRX114799_toassemble_2.fq
```

Each candidate FASTQ contained:

```text
5684 lines
```

Because one FASTQ read occupies four lines:

```text
5684 / 4 = 1421 reads
```

Therefore TRUST4 selected:

- **1,421 R1 reads**
- **1,421 R2 reads**
- **1,421 candidate paired-end fragments**

from the original 3,511,391 RNA-seq fragments.

These should be interpreted as candidate receptor-related reads selected for assembly, not as confirmed TCR/BCR reads.

---

## 8. Paired-End Validation

To confirm that paired-end relationships were preserved after candidate extraction, the FASTQ headers from R1 and R2 were compared.

Example:

```text
R1:
@SRR396928.2671

R2:
@SRR396928.2671
```

The sequence contents differed, as expected for opposite ends of the same fragment, but the fragment identifiers matched.

All candidate R1 and R2 headers were compared using:

```bash
diff \
  <(awk 'NR % 4 == 1' ~/technical_test/results/trust4/SRX114799_toassemble_1.fq) \
  <(awk 'NR % 4 == 1' ~/technical_test/results/trust4/SRX114799_toassemble_2.fq)
```

The command returned no output, confirming that the candidate R1 and R2 identifiers matched in the same order.

The number of unique fragment identifiers across both files was also checked:

```bash
cat \
  <(awk 'NR % 4 == 1' ~/technical_test/results/trust4/SRX114799_toassemble_1.fq) \
  <(awk 'NR % 4 == 1' ~/technical_test/results/trust4/SRX114799_toassemble_2.fq) \
  | sort -u | wc -l
```

Result:

```text
1421
```

This confirmed that the candidate-read extraction retained **1,421 paired fragments**.

---

## 9. Assembly

The TRUST4 log reported:

```text
Found 2690 reads.
Assembled 1624 reads.
Try to rescue 130 reads for assembly.
Rescued 11 reads.
```

The file:

```text
SRX114799_assembled_reads.fa
```

contained:

```bash
grep -c '^>' ~/technical_test/results/trust4/SRX114799_assembled_reads.fa
```

Result:

```text
1635
```

This is consistent with:

```text
1624 assembled reads + 11 rescued reads = 1635
```

The records in `assembled_reads.fa` retained original SRR read identifiers, so the 1,635 records were interpreted as reads incorporated/rescued during 
assembly rather than 1,635 independent receptor clonotypes.

---

## 10. Main TRUST4 Output Files

The analysis generated the following important files:

```text
SRX114799_raw.out
SRX114799_final.out
SRX114799_assembled_reads.fa
SRX114799_annot.fa
SRX114799_cdr3.out
SRX114799_report.tsv
SRX114799_airr.tsv
SRX114799_airr_align.tsv
SRX114799_toassemble_1.fq
SRX114799_toassemble_2.fq
```

A useful simplified view of the pipeline is:

```text
Raw RNA-seq FASTQs
        ↓
Candidate read extraction
        ↓
toassemble_1.fq / toassemble_2.fq
        ↓
Assembly
        ↓
raw.out / final.out / assembled_reads.fa
        ↓
V(D)J annotation + CDR3 analysis
        ↓
annot.fa / cdr3.out
        ↓
Simplified repertoire + AIRR output
        ↓
report.tsv / airr.tsv
```

---

## 11. Understanding `annot.fa`

`SRX114799_annot.fa` contains reconstructed sequences together with detailed immune-receptor annotation.

For example, `assemble0` was:

```text
>assemble0 550 23.72 IGKV1-33*01|IGKV1D-33*01 ... IGKJ2*01 ... IGKC ...
CDR2(...)=GATGCATCC
CDR3(...)=TGTCAGCAGTATGATAATCTGCCTCACACCTTT
```

This showed a reconstructed immunoglobulin kappa (IGK) sequence with:

- V: `IGKV1-33*01|IGKV1D-33*01`
- no D assignment
- J: `IGKJ2*01`
- C: `IGKC`
- CDR2 nucleotide sequence: `GATGCATCC`
- CDR3 nucleotide sequence: `TGTCAGCAGTATGATAATCTGCCTCACACCTTT`

This confirmed that TRUST4 successfully reconstructed adaptive immune receptor sequences from the RNA-seq dataset.

---

## 12. Understanding `cdr3.out`

The same receptor appeared in:

```text
SRX114799_cdr3.out
```

as:

```text
assemble0    0    IGKV1-33*01|IGKV1D-33*01    *    IGKJ2*01    IGKC    *    GATGCATCC    TGTCAGCAGTATGATAATCTGCCTCACACCTTT    1.00    5.00    93.55    0
```

This file contains compact CDR/receptor records derived from the assembled and annotated receptor sequences.

Importantly, `cdr3.out` contains no header, so numerical fields whose meanings were not directly self-evident were not overinterpreted.

---

## 13. Understanding `report.tsv`

The simplified repertoire file has the header:

```text
#count
frequency
CDR3nt
CDR3aa
V
D
J
C
cid
cid_full_length
```

For `assemble0`, the record was:

```text
count            5
frequency        8.771930e-02
CDR3nt           TGTCAGCAGTATGATAATCTGCCTCACACCTTT
CDR3aa           CQQYDNLPHTF
V                IGKV1-33*01|IGKV1D-33*01
D                .
J                IGKJ2*01
C                IGKC
cid              assemble0
cid_full_length  0
```

This demonstrated that TRUST4 successfully translated CDR3 nucleotide sequences into amino-acid CDR3 sequences and provided repertoire abundance 
information.

The value `count = 5` should be interpreted as TRUST4-supported abundance for this CDR3 record rather than as five cells.

---

## 14. BCR Repertoire Observation

Inspection of `report.tsv` showed many B-cell receptor entries, particularly immunoglobulin kappa (IGK) rearrangements.

Example CDR3 amino-acid sequences included:

```text
CQQYDNLPHTF
CQQSYSIPYTF
CQQYGGSQYTF
CQQYNTYSTF
CMQHTHWPLSF
```

Therefore, TRUST4 clearly recovered a B-cell receptor repertoire from this RNA-seq sample.

---

## 15. TCR-Specific Analysis

The primary technical-assessment question was whether TRUST4 could recover TCR information.

### 15.1 TCR-associated assemblies in `annot.fa`

Searching the annotated assemblies for TCR genes identified partial TRA/TRB-associated sequences, including assignments such as:

```text
TRAV35*01
TRAV38-2/DV8*01
TRAV12-2*01
TRAV12-3*01
TRAV8-2*01
TRAJ29*01

TRBV20-1*01
TRBV6-1*01
TRBJ2-1*01
TRBC2
```

However, these TCR-associated assemblies showed:

```text
CDR3 = null
```

meaning TRUST4 could annotate portions of TCR genes but could not reconstruct a complete CDR3 for those assemblies.

### 15.2 Count of TCR-associated assemblies

The total number of TCR-associated annotated assemblies was checked with:

```bash
grep -E '^>.*(TRAV|TRAJ|TRBV|TRBD|TRBJ|TRBC)' \
  ~/technical_test/results/trust4/SRX114799_annot.fa \
  | wc -l
```

Result:

```text
10
```

These were further separated into TRA and TRB-associated assemblies.

TRA:

```bash
grep -E '^>.*(TRAV|TRAJ)' \
  ~/technical_test/results/trust4/SRX114799_annot.fa | wc -l
```

Result:

```text
6
```

TRB:

```bash
grep -E '^>.*(TRBV|TRBD|TRBJ|TRBC)' \
  ~/technical_test/results/trust4/SRX114799_annot.fa | wc -l
```

Result:

```text
4
```

Therefore:

```text
10 total TCR-associated assemblies
├── 6 TRA-associated
└── 4 TRB-associated
```

These counts refer to annotated assemblies, not complete clonotypes.

---

## 16. Double-Checking the TCR Result

Because no complete TCR CDR3 had been observed in `annot.fa`, the downstream files were independently checked.

### 16.1 Check `cdr3.out`

Command:

```bash
grep -E 'TRAV|TRAJ|TRBV|TRBD|TRBJ' \
  ~/technical_test/results/trust4/SRX114799_cdr3.out
```

Result:

```text
No output
```

Interpretation:

No TCR CDR3 records were present in `cdr3.out`.

---

### 16.2 Check `report.tsv`

TCR gene names were searched in the final simplified repertoire output.

No TRA or TRB clonotypes were found.

Therefore, no final TCR clonotype was reported in `report.tsv`.

---

### 16.3 Check AIRR-standardized output

The AIRR file contained columns including:

```text
sequence_id
sequence
productive
locus
v_call
d_call
j_call
c_call
junction
junction_aa
complete_vdj
consensus_count
```

For example, the BCR record `assemble0_0` contained:

```text
productive       T
locus            IGK
v_call           IGKV1-33*01|IGKV1D-33*01
j_call           IGKJ2*01
c_call           IGKC
junction          TGTCAGCAGTATGATAATCTGCCTCACACCTTT
junction_aa       CQQYDNLPHTF
consensus_count   5
```

TRA/TRB loci were then explicitly queried:

```bash
awk -F'\t' 'NR==1 || $5=="TRA" || $5=="TRB"' \
  ~/technical_test/results/trust4/SRX114799_airr.tsv
```

The result contained only the header.

Therefore:

```text
TRA records in airr.tsv = 0
TRB records in airr.tsv = 0
```

---

## 17. Final TRUST4 Result

The TRUST4 analysis successfully processed the RNA-seq data and reconstructed adaptive immune receptor sequences.

For TCR specifically:

- **10 partial TCR-associated assemblies were detected**
- **6 were TRA-associated**
- **4 were TRB-associated**
- all lacked a complete CDR3 annotation
- **0 TCR CDR3 records were present in `cdr3.out`**
- **0 TCR clonotypes were present in `report.tsv`**
- **0 TRA/TRB records were present in `airr.tsv`**

Therefore, the final interpretation is:

> TRUST4 detected partial TCR-associated sequence evidence, including 6 TRA-associated and 4 TRB-associated assemblies. However, none yielded a complete TCR 
CDR3, and no TRA/TRB clonotypes were present in the final CDR3, repertoire, or AIRR outputs.

This should not be interpreted as TRUST4 finding no TCR-related sequence at all. Instead, the data contained partial TCR signal, but the available RNA-seq 
coverage was insufficient for TRUST4 to reconstruct complete reportable TCR clonotypes.

---

## 18. Workflow Validation

The TRUST4 workflow was reviewed to make sure an important processing step or option had not been omitted.

The following were confirmed:

- Raw paired-end FASTQ input is supported.
- The four runs belong to the same RNA-seq experiment/sample/library.
- Wildcard input for paired FASTQ files is supported.
- `hg38_bcrtcr.fa` is appropriate for human receptor-read extraction.
- `human_IMGT+C.fa` is appropriate for detailed receptor annotation.
- `--repseq` is intended for targeted bulk non-UMI TCR-seq/BCR-seq and was therefore not used for this ordinary transcriptomic bulk RNA-seq dataset.
- Candidate extraction, assembly, annotation, CDR3 analysis, repertoire generation, and AIRR export all completed successfully.

Based on these checks, no missing core TRUST4 processing step was identified.

---

## 19. Troubleshooting / Notes

### macOS `sed` compatibility

An initial attempt to extract every fourth FASTQ line using GNU-style `sed` syntax failed on macOS because BSD `sed` does not support the same `1~4` 
addressing syntax.

Instead, the portable `awk` command was used:

```bash
awk 'NR % 4 == 1'
```

This successfully extracted FASTQ headers for R1/R2 pairing validation.

### TRUST4 help behavior

Running:

```bash
./run-trust4 --help
```

reported the TRUST4 version but also returned:

```text
Unknown parameter --help
```

This did not indicate a failed installation. The wrapper simply does not implement `--help` in the usual command-line style.

---

## 20. Timing Summary

| Step | Time |
|---|---:|
| TRUST4 compilation (`make`) | 17.549 s |
| TRUST4 pooled RNA-seq analysis | 44.013 s |
| Output inspection / validation | Manual analysis |
| Troubleshooting | Minor macOS command compatibility issue |

"""
