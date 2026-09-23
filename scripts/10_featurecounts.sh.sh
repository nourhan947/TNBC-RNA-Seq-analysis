#!/bin/bash

mkdir -p ~/rnaseq_project/counts

featureCounts \
  -T 6 \
  -p --countReadPairs \
  -s 0 \
  -a ~/rnaseq_project/Homo_sapiens.GRCh38.116.gtf \
  -o ~/rnaseq_project/counts/gene_counts.txt \
  ~/rnaseq_project/alignments_rRNA_clean/SRR15852393_clean_Aligned.sortedByCoord.out.bam \
  ~/rnaseq_project/alignments_rRNA_clean/SRR15852394_clean_Aligned.sortedByCoord.out.bam \
  /media/sf_course_data/alignments/SRR15852424_Aligned.sortedByCoord.out.bam \
  /media/sf_course_data/alignments/SRR15852425_Aligned.sortedByCoord.out.bam
