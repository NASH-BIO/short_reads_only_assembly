#!/bin/bash

# initialize conda for this script
eval "$(conda shell.bash hook)"

# Where the raw reads are stored
SOURCE_DIR="/home/neha/03_wgs_assembly/hybrid_genome_assembly_guide/01_raw_reads/short_reads"

# Work inside the CURRENT directory (short_reads_only_assembly)
WORK_DIR="$(pwd)"

echo "Working in: ${WORK_DIR}"

# Create directories in the current folder
mkdir -p "${WORK_DIR}/00_raw_reads"
mkdir -p "${WORK_DIR}/01_qc_before_processing"
mkdir -p "${WORK_DIR}/02_process_reads"
mkdir -p "${WORK_DIR}/03_qc_after_processing"
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

#run fastp for read trimming and filtering
cd "${WORK_DIR}/02_process_reads"
conda activate 01_short_read_qc
fastp \
  -i "${WORK_DIR}/00_raw_reads/codanics_1.fastq.gz" \
  -I "${WORK_DIR}/00_raw_reads/codanics_2.fastq.gz" \
  -o "${WORK_DIR}/02_process_reads/codanics_1_processed.fastq.gz" \
  -O "${WORK_DIR}/02_process_reads/codanics_2_processed.fastq.gz" \
  -q 25 \
  -h "${WORK_DIR}/03_qc_after_processing/fastp_report.html" \
  -j "${WORK_DIR}/03_qc_after_processing/fastp_report.json" \
  -w 12

# fastqc and multi qc run on processed reads
cd "${WORK_DIR}/03_qc_after_processing"
conda activate 01_short_read_qc
mkdir reports_fastqc_processed
fastqc -o reports_fastqc_processed --extract --svg -t 12 "${WORK_DIR}/02_process_reads/"*.fastq.gz
# run multiqc on fastqc files of processed reads
conda activate 02_multiqc
multiqc -p -o "${WORK_DIR}/03_qc_after_processing/multiqc/fastqc_multiqc_processed" ./
echo ""
echo "Quality control and read processing completed."