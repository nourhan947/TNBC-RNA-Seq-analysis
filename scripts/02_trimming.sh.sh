#!/bin/bash
source /home/nourhan/miniconda3/etc/profile.d/conda.sh
conda activate rnaseq_project

#Step 2 trimming with fastp
#Directories
DATASET_DIR="/media/sf_course_data/raw_data"
TRIMMING_DIR="/media/sf_course_data/trimming_output"

#Creat output directory
mkdir -p $TRIMMING_DIR
#Run fastp for all sample 
for sample in SRR15852393 SRR15852394 SRR15852395 SRR15852423 SRR15852424  SRR15852425
do
echo "Trimming: $sample"
fastp \
-i ${DATASET_DIR}/${sample}_1.fastq \
-I ${DATASET_DIR}/${sample}_2.fastq \
-o ${TRIMMING_DIR}/${sample}_1.paired.fastq \
-O ${TRIMMING_DIR}/${sample}_2.paired.fastq  \
--thread 4 \
--qualified_quality_phred 20 \
--length_required 36 \
--detect_adapter_for_pe \
--html ${TRIMMING_DIR}/${sample}_fastp.html \
--json ${TRIMMING_DIR}/${sample}_fastp.json
done
