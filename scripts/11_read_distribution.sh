#!bin/bash

#RSeQC gDNA contamination check

read_distribution.py -i /media/sf_course_data/alignments/SRR15852423_Aligned.sortedByCoord.out.bam -r ~/rnaseq_project/Homo_sapiens.GRCh38.116.bed
Processing /home/nourhan/rnaseq_project/Homo_sapiens.GRCh38.116.bed ... Done
Processing /media/sf_course_data/alignments/SRR15852423_Aligned.sortedByCoord.out.bam ... Finished

Total Reads                   65634348
Total Tags                    68183939
Total Assigned Tags           55271216
=====================================================================
Group               Total_bases         Tag_count           Tags/Kb             
CDS_Exons           38682242            1407410             36.38             
5'UTR_Exons         70852648            1803321             25.45             
3'UTR_Exons         112794562           2713565             24.06             
Introns             1869056157          43535784            23.29             
TSS_up_1kb          26264603            374747              14.27             
TSS_up_5kb          117719284           1527025             12.97             
TSS_up_10kb         207658883           2739891             13.19             
TES_down_1kb        30486439            402899              13.22             
TES_down_5kb        130054298           1748144             13.44             
TES_down_10kb       223780001           3071245             13.72      
=====================================================================
read_distribution.py -i /media/sf_course_data/alignments/SRR15852424_Aligned.sortedByCoord.out.bam -r ~/rnaseq_project/Homo_sapiens.GRCh38.116.bed
Processing /home/nourhan/rnaseq_project/Homo_sapiens.GRCh38.116.bed ... Done
Processing /media/sf_course_data/alignments/SRR15852424_Aligned.sortedByCoord.out.bam ... Finished

Total Reads                   61060638
Total Tags                    68953998
Total Assigned Tags           63834160
=====================================================================
Group               Total_bases         Tag_count           Tags/Kb             
CDS_Exons           38682242            17829242            460.92            
5'UTR_Exons         70852648            5448495             76.90             
3'UTR_Exons         112794562           7379320             65.42             
Introns             1869056157          31638225            16.93             
TSS_up_1kb          26264603            28937               1.10              
TSS_up_5kb          117719284           104177              0.88              
TSS_up_10kb         207658883           179623              0.86              
TES_down_1kb        30486439            82405               2.70              
TES_down_5kb        130054298           1206152             9.27              
TES_down_10kb       223780001           1359255             6.07              
=====================================================================
