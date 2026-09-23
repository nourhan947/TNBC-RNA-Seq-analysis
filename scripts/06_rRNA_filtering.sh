#!/bin/bash
TRIMMING_DIR=~/rnaseq_project/trimmed
RRNA_OUTPUT=~/rnaseq_project/rRNA_filtered

mkdir -p "$RRNA_OUTPUT" 

for sample in SRR15852393 SRR15852394 SRR15852395
do
  echo "Filtering rRNA from: $sample"
  bowtie2 -x ~/rRNA_index \
    -1 ${TRIMMING_DIR}/${sample}_1.paired.fastq.gz \
    -2 ${TRIMMING_DIR}/${sample}_2.paired.fastq.gz \
    --un-conc ~/rnaseq_project/rRNA_filtered/${sample}_rRNA_removed_%.fastq \
    -S /dev/null \
    --threads 6
done
