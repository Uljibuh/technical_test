#!/bin/bash

# Prepare merged paired-end FASTQ input for OptiType

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

DATA_DIR="$PROJECT_DIR/data"
OUTPUT_DIR="$DATA_DIR/optitype_input"

RUNS=(
    SRR396928
    SRR397000
    SRR397072
    SRR397144
)

mkdir -p "$OUTPUT_DIR"

R1_OUTPUT="$OUTPUT_DIR/SRX114799_R1.fastq.gz"
R2_OUTPUT="$OUTPUT_DIR/SRX114799_R2.fastq.gz"

echo "=== Checking source FASTQ files ==="

for run in "${RUNS[@]}"; do
    for mate in 1 2; do
        file="$DATA_DIR/${run}_${mate}.fastq.gz"

        if [[ ! -f "$file" ]]; then
            echo "ERROR: Missing $file"
            echo "Run scripts/02_download_data.sh first."
            exit 1
        fi
    done
done

echo "All source FASTQ files found."

echo
echo "=== Creating merged R1 ==="

cat \
    "$DATA_DIR/SRR396928_1.fastq.gz" \
    "$DATA_DIR/SRR397000_1.fastq.gz" \
    "$DATA_DIR/SRR397072_1.fastq.gz" \
    "$DATA_DIR/SRR397144_1.fastq.gz" \
    > "$R1_OUTPUT"

echo "=== Creating merged R2 ==="

cat \
    "$DATA_DIR/SRR396928_2.fastq.gz" \
    "$DATA_DIR/SRR397000_2.fastq.gz" \
    "$DATA_DIR/SRR397072_2.fastq.gz" \
    "$DATA_DIR/SRR397144_2.fastq.gz" \
    > "$R2_OUTPUT"

echo
echo "=== Checking gzip integrity ==="

gzip -t "$R1_OUTPUT"
gzip -t "$R2_OUTPUT"

echo "Gzip integrity checks passed."

echo
echo "=== Checking read counts ==="

R1_LINES=$(gzcat "$R1_OUTPUT" | wc -l | tr -d ' ')
R2_LINES=$(gzcat "$R2_OUTPUT" | wc -l | tr -d ' ')

R1_READS=$((R1_LINES / 4))
R2_READS=$((R2_LINES / 4))

echo "R1 reads: $R1_READS"
echo "R2 reads: $R2_READS"

if [[ "$R1_READS" -ne "$R2_READS" ]]; then
    echo "ERROR: R1 and R2 read counts do not match."
    exit 1
fi

echo
echo "OptiType input preparation completed successfully."
echo "Paired-end fragments: $R1_READS"
echo
echo "Output:"
echo "  $R1_OUTPUT"
echo "  $R2_OUTPUT"
