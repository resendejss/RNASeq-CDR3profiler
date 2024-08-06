#!/usr/bin/env bash

################################################################
# quality-control.sh
#
# Uso: ./quality-control.sh
#
# Author: Jean Resende (jean.s.s.resende@gmail.com)
#
################################################################

# Function to check if FastQC is installed
check_fastqc() {
    if ! command -v fastqc &> /dev/null
    then
        echo "FastQC not found. Please install FastQC"
        exit 1
    fi
}

# Function to check if MultiQC is installed
check_multiqc() {
    if ! command -v multiqc &> /dev/null
    then
        echo "MultiQC not found. Please install MultiQC."
        exit 1
    fi
}

# Function to process FASTQ files with FastQC
run_fastqc() {
    for file in "$1"/*.{fq,fastq,fastq.gz}; do
        if [ -f "$file" ]; then
            echo "Processing $file with FastQC..."
            fastqc "$file" -o "$2"
        fi
    done
}

# Requests the folder where the FASTQ files are located
read -p "Enter the folder path where the FASTQ files are located: " input_dir

# Requests the folder where FasQC results will be saved
read -p "Enter the folder path where FastQC results will be saved: " output_dir_fastqc

# Requests the folder where MultiQC results will be saved
read -p "Enter the folder path where MultiQC results will be saved: " output_dir_multiqc

# Checks if the input folder exists
if [ ! -d "$input_dir" ]; then
    echo "The input folder does not exist. Please check the path and try again."
    exit 1
fi

# Createe output folders if they do not exists
mkdir -p "$output_dir_fastqc"
mkdir -p "$output_dir_multiqc"

# Checks if FastQC and MultiQC are installed
check_fastqc
check_multiqc

# Run FastQC on FASTQ files
run_fastqc "$input_dir" "$output_dir_fastqc"

# Generate a consolidated report with MultiQC
echo "Generating consolidated reports with MultiQC ..."
multiqc "$output_dir_fastqc" -o "$output_dir_multiqc"

echo "Complete quality control. FastQC results were saved in $output_dir_fastqc and MultiQC results were saved in $output_dir_multiqc"
