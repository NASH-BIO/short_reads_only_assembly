#!/bin/bash

# initialize conda for this script
eval "$(conda shell.bash hook)"

# Where the raw reads are stored
SOURCE_DIR="/home/neha/03_wgs_assembly/hybrid_genome_assembly_guide/01_raw_reads/short_reads"

# Work inside the CURRENT directory (short_reads_only_assembly)
WORK_DIR="$(pwd)"

echo "Working in: ${WORK_DIR}"

# Create directories in the current folder
mkdir -p 00_raw_reads
mkdir -p 01_qc_before_processing
mkdir -p 02_process_reads
mkdir -p 03_qc_after_processing

echo "---------------------------------------------------"
echo "Directories created in: ${WORK_DIR}"
echo "---------------------------------------------------"

# Copy short reads (.fastq.gz files) into 00_raw_reads
cp "${SOURCE_DIR}"/*.fastq.gz "${WORK_DIR}/00_raw_reads/"

echo "Short reads copied to ${WORK_DIR}/00_raw_reads/"
ls -la "${WORK_DIR}/00_raw_reads/"
echo "---------------------------------------------------"

# Rename files to codanics_1.fastq.gz and codanics_2.fastq.gz
cd "${WORK_DIR}/00_raw_reads/"

mv *_1.fastq.gz codanics_1.fastq.gz
mv *_2.fastq.gz codanics_2.fastq.gz

echo "Renamed files:"
ls -la
echo "---------------------------------------------------"
echo "Raw reads copied."
ls -la "${WORK_DIR}/00_raw_reads/"
echo "---------------------------------------------------"

# Change to QC before processing directory
cd "${WORK_DIR}/01_qc_before_processing"
# run fastqc
conda activate 01_short_read_qc
# expert use case
mkdir reports
fastqc -o reports --extract --svg -t 12 "${WORK_DIR}/00_raw_reads/"*.fastq.gz

# run multiqc on fastqc files
conda activate 02_multiqc
#expert use case of multiqc
multiqc -p -o "${WORK_DIR}/01_qc_before_processing/multiqc/fastqc_multiqc" ./

