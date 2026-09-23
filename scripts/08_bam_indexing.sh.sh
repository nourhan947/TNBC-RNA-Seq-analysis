#!/bin/bash
#Post Alignment processing

BAMS=( 
       ~/rnaseq_project/alignments_rRNA_clean/SRR15852393_clean_Aligned.sortedByCoord.out.bam  
       ~/rnaseq_project/alignments_rRNA_clean/SRR15852394_clean_Aligned.sortedByCoord.out.bam  
       /media/sf_course_data/alignments/SRR15852423_Aligned.sortedByCoord.out.bam 
      /media/sf_course_data/alignments/SRR15852424_Aligned.sortedByCoord.out.bam 
    /media/sf_course_data/alignments/SRR15852425_Aligned.sortedByCoord.out.bam
)
for bam in "${BAMS[@]}"
do
echo "indexing: $bam"
samtools index "$bam"
done
