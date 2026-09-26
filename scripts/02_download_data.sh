#!/bin/bash

# Download RNA-seq FASTQ files for ENA experiment SRX114799

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="$PROJECT_DIR/data"

mkdir -p "$DATA_DIR"

RUNS=(
    SRR396928
    SRR397000
    SRR397072
    SRR397144
)

echo "=== Downloading SRX114799 RNA-seq data ==="
echo "Destination: $DATA_DIR"
echo

for run in "${RUNS[@]}"; do
    echo "Processing $run..."

    urls=$(curl -fsSL \
        "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${run}&result=read_run&fields=fastq_ftp&format=tsv" \
        | tail -n 1)

    IFS=';' read -ra files <<< "$urls"

    for url in "${files[@]}"; do
        filename=$(basename "$url")

        if [[ -f "$DATA_DIR/$filename" ]]; then
            echo "  Already exists: $filename"
        else
            echo "  Downloading: $filename"
            curl -L \
                "https://$url" \
                -o "$DATA_DIR/$filename"
        fi
    done

    echo
done

echo "=== Checking gzip integrity ==="

gzip -t "$DATA_DIR"/*.fastq.gz

echo "All downloads completed and gzip checks passed."
