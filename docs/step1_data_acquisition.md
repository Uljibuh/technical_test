# Step 1 — RNA-seq Data Acquisition and Inspection

## 1. Dataset Information

Dataset source: European Nucleotide Archive (ENA)

Experiment accession: SRX114799
Organism: Homo sapiens
Sequencing platform: Illumina HiSeq 2000
Library strategy: RNA-Seq
Library source: Transcriptomic
Library selection: cDNA
Library layout: Paired-end

Study accession: PRJNA274775
Sample accession: SAMN00771119

The experiment contains four sequencing runs:

- SRR396928
- SRR397000
- SRR397072
- SRR397144

Because the experiment used paired-end sequencing, each run contains
two FASTQ files:

_1.fastq.gz = Read 1 (R1)
_2.fastq.gz = Read 2 (R2)

Therefore, the experiment contains 8 FASTQ files in total.


## 2. Raw Data Location

The FASTQ files were downloaded to:

technical_test/data/

Files:

SRR396928_1.fastq.gz
SRR396928_2.fastq.gz
SRR397000_1.fastq.gz
SRR397000_2.fastq.gz
SRR397072_1.fastq.gz
SRR397072_2.fastq.gz
SRR397144_1.fastq.gz
SRR397144_2.fastq.gz


## 3. What the Data Represent

These files contain raw paired-end RNA-seq reads generated from a
human transcriptomic cDNA library.

For each sequenced cDNA fragment, Illumina sequencing generates two
reads:

R1 = sequence read from one end of the cDNA fragment
R2 = sequence read from the opposite end

R1 and R2 therefore correspond to the same original fragment and are
not independent biological samples.

The four SRR accessions represent four sequencing runs belonging to
the same ENA experiment, SRX114799.


## 4. FASTQ Integrity Check

All downloaded compressed FASTQ files were checked using:

gzip -t *.fastq.gz

No errors were returned, indicating that all eight gzip files passed
the integrity check.


## 5. Paired-End Read Count Check

FASTQ line counts were obtained using:

for f in *.fastq.gz; do
  echo -n "$f: "
  gzcat "$f" | wc -l
done

Each FASTQ read occupies four lines. Therefore:

number of reads = number of FASTQ lines / 4

Results:

SRR396928:
R1 = 1,118,863 reads
R2 = 1,118,863 reads

SRR397000:
R1 = 807,512 reads
R2 = 807,512 reads

SRR397072:
R1 = 788,955 reads
R2 = 788,955 reads

SRR397144:
R1 = 796,061 reads
R2 = 796,061 reads

All four runs have matching R1 and R2 read counts.

Total = 3,511,391 paired-end fragments
Total individual reads = 7,022,782


## 6. Purpose of Downstream Analysis

This is general human RNA-seq data rather than targeted TCR sequencing.

MiXCR and TRUST4 will be used to identify RNA-seq reads originating
from T-cell receptor transcripts and reconstruct TCR information,
including CDR3 sequences and V/D/J gene usage.

OptiType will use RNA-seq reads informative for HLA class I genes to
predict two alleles for each of:

HLA-A
HLA-B
HLA-C


## 7. Troubleshooting / Notes

1. Initial inspection of the ENA experiment showed that SRX114799
   contains four sequencing runs rather than a single run.

2. All four runs were therefore downloaded, producing eight FASTQ
   files because the experiment uses paired-end sequencing.

3. URL formatting caused an issue during command-line downloading.
   The download procedure was adjusted and all resulting FASTQ files
   were subsequently validated.

4. gzip integrity testing returned no errors.

5. R1 and R2 read counts matched for every sequencing run.


## 8. Timing

FASTQ files were approximately 23–35 MB each.

Individual downloads generally required tens of seconds per file.

Exact command runtimes will be recorded for subsequent analysis steps.
