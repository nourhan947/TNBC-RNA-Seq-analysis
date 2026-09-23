#!/bin/bash

conda install rseqc
conda install ucsc-gtftogenepred ucsc-genepredtobed   

~/rnaseq_project/gtfToGenePred Homo_sapiens.GRCh38.116.gtf Homo_sapiens.GRCh38.116.genePred
~/rnaseq_project/genePredToBed Homo_sapiens.GRCh38.116.genePred Homo_sapiens.GRCh38.116.bed
 infer_experiment.py -r ~/rnaseq_project/Homo_sapiens.GRCh38.116.bed -i ~/rnaseq_project/alignments_rRNA_clean/SRR15852393_clean_Aligned.sortedByCoord.out.bam


This is PairEnd Data
Fraction of reads failed to determine: 0.1401
Fraction of reads explained by "1++,1--,2+-,2-+": 0.4272
Fraction of reads explained by "1+-,1-+,2++,2--": 0.4327
 read_distribution.py -i /media/sf_course_data/alignments/SRR15852423_Aligned.sortedByCoord.out.bam -r ~/rnaseq_project/Homo_sapiens.GRCh38.116.bed
