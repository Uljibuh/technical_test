#!/bin/bash

# Step 1: Validate downloaded RNA-seq FASTQ files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="$PROJECT_DIR/data"

cd "$DATA_DIR"

echo "=== FASTQ files ==="
ls -lh *.fastq.gz

echo
echo "=== Checking gzip integrity ==="
gzip -t *.fastq.gz
echo "All gzip integrity checks passed."

echo
echo "=== FASTQ line counts ==="
for f in *.fastq.gz; do
    echo -n "$f: "
    gzcat "$f" | wc -l
done
