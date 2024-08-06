#!/usr/bin/env bash

################################################################
# trimming.sh
#
# Uso: ./trimming.sh
#
# Author: Jean Resende (jean.s.s.resende@gmail.com)
# 
################################################################

# Function to check if Trimmomatic is installed
check_trimmomatic() {
    if ! command -v TrimmomaticPE &> /dev/null
    then
        echo "Trimmomatic not found. Please install Trimmomatic"
        exit 1
    fi
}

# Function to process FASTQ files with Trimmomatic
run_trimmomatic() {
    local input_r1=$1
    local input_r2=$2
    local output_paired_r1=$3
    local output_unpaired_r1=$4
    local output_paired_r2=$5
    local output_unpaired_r2=$6

    trimmomatic PE -threads 4 \
                   "$input_r1" "$input_r2" \
                   "$output_paired_r1" "$output_unpaired_r1" \
                   "$output_paired_r2" "$output_unpaired_r2" \
                   ILLUMINACLIP:TruSeq3-PE-2.fa:2:30:10 \
                   LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
}

# Requests the foldeer where the FASTQ files aree located
read -p "Enter the folder path where FASTQ files are located: " input_dir

# Requests the folder where the trimming results will be saved
read -p "Enter the folder path where the trimming results will be saved: " output_dir

# Checks if the input folder exists
if [ ! -d "$input_dir" ]; then
    echo "The input folder does not exist. Please check the path and try again."
    exit 1
fi

# Create output folder if it doesn't exist
mkdir -p "$output_dir"

# Check if Trimmomatic is installed
check_trimmomatic

# Loop to process each pair of R1 and R2 files found in the input folder
for r1_file in "$input_dir"/*_R1.{fq,fastq,fastq.gz}; do
    r2_file="${r1_file/_R1/_R2}"
    
    if [ -f "$r2_file" ]; then
        echo "Processing $r1_file and $r2_file with Trimmomatic ..."
        
        # Constrói os nomes de saída baseados nos nomes dos arquivos de entrada
        sample_name=$(basename "$r1_file" | cut -d'_' -f1)
        output_paired_r1="$output_dir/${sample_name}_R1_trimmomatic_paired.fastq.gz"
        output_unpaired_r1="$output_dir/${sample_name}_R1_trimmomatic_unpaired.fastq.gz"
        output_paired_r2="$output_dir/${sample_name}_R2_trimmomatic_paired.fastq.gz"
        output_unpaired_r2="$output_dir/${sample_name}_R2_trimmomatic_unpaired.fastq.gz"
        
        # Executa Trimmomatic para trimar os arquivos
        run_trimmomatic "$r1_file" "$r2_file" \
                        "$output_paired_r1" "$output_unpaired_r1" \
                        "$output_paired_r2" "$output_unpaired_r2"
    else
        echo "Arquivo correspondente R2 não encontrado para $r1_file. Pulando para o próximo."
    fi
done

echo "Trimagem completa. Os resultados foram salvos em $output_dir"