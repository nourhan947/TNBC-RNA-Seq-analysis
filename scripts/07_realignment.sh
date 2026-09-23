#!/bin/bash
TRIMMED_RRNA_DIR=~/rnaseq_project/rRNA_filtered
GENOME_INDEX_DIR=~/rnaseq_project/star_index
OUT_DIR=~/rnaseq_project/alignments_rRNA_clean

mkdir -p "$OUT_DIR"

for sample in SRR15852393 SRR15852394 SRR15852395
do
  echo "Aligning (rRNA-cleaned): $sample"
  STAR --runThreadN 6 \
    --genomeDir "$GENOME_INDEX_DIR" \
    --readFilesIn ${TRIMMED_RRNA_DIR}/${sample}_rRNA_removed_1.fastq ${TRIMMED_RRNA_DIR}/${sample}_rRNA_removed_2.fastq \
    --outFileNamePrefix ${OUT_DIR}/${sample}_clean_ \
    --outSAMtype BAM SortedByCoordinate \
    --limitBAMsortRAM 15000000000  
done
