#!/bin/bash
#-------------------
#Installation &Setup 
#--------------------
#Step1 Download Miniconda installer
 curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
#Navigate to your home directory and execute the installation script:
sh Miniconda3-latest-Linux-x86_64.sh
#------------------------------------------------------
#create and activate an environment for RNA seq analysis
#-------------------------------------------------------
conda creat -n rnaseq_project -y
conda activate rnaseq_project

#Configure conda channels
—--------------------------------
 conda config --add channels defaults
 conda config --add channels bioconda
 conda config --add channels conda-forge
 conda config --set channel_priority strict
—-----------------------
#install required tools
---------------------------
conda install fastqc multiqc --channel conda-forge --channel bioconda --strict channela-priority
conda install -y bioconda::trimmomatic
conda install star samtools --channel conda-forge --channel bioconda --strict-channel-priority
conda install subread --channel conda-forge --channel bioconda --strict-channel-priority
conda install -c bioconda sra-tools
conda install bioconda::fastp

##Download Data

prefetch SRR15852393 SRR15852394 SRR15852395 SRR15852423 SRR15852424 SRR15852425

# extract data using fasterq-dumb from SRA accession 

for sample in SRR15852393 SRR15852394 SRR15852395 SRR15852423 SRR15852424 SRR15852425
do
      fasterq-dump --split-files /media/sf_course_data/raw_data/sra/$sample.sra/
Done
# Download reference genome 
wget -P /media/sf_course_data/RAdataset \ "http://ftp.ensembl.org/pub/release-116/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz" 
wget -P /media/sf_course_data/RAdataset https://ftp.ensembl.org/pub/release-109/gtf/homo_sapiens/Homo_sapiens.GRCh38.116.gtf.gz
