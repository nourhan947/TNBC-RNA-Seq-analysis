 #!bin/bash
#Step 1 Quality Control QC

#Directories

DATASET_DIR="/media/sf_course_data/raw_data"
QC_OUTPUT_DIR="/media/sf_course_data/qc_reports"

mkdir -p $QC_OUTPUT_DIR
#Run fastq for all fasta files
fastqc -o ${QC_OUTPUT_DIR} $DATASET_DIR/SRR15852393_2.fastq

#Aggergate QC reports using multiQC
multiqc  -o $QC_OUTPUT_DIR $QC_OUTPUT_DIR

