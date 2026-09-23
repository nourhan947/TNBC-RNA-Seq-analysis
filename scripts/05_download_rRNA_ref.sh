#!/bin/bash
mkdir -p ~/rnaseq_project/rRNA_ref
cd ~/rnaseq_project/rRNA_ref

# 45S pre-ribosomal RNA precursor variants (identified from  BLAST results)
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NR_145819.1&rettype=fasta&retmode=text" > RNA45SN1.fasta
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NR_146144.1&rettype=fasta&retmode=text" > RNA45SN2.fasta
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NR_146151.1&rettype=fasta&retmode=text" > RNA45SN3.fasta
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NR_146117.1&rettype=fasta&retmode=text" > RNA45SN4.fasta
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NR_046235.3&rettype=fasta&retmode=text" > RNA45SN5.fasta

# Mature rRNA subunits (for completeness)
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NR_003286.4&rettype=fasta&retmode=text" > 18S.fasta
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NR_003285.3&rettype=fasta&retmode=text" > 5_8S.fasta
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NR_003287.4&rettype=fasta&retmode=text" > 28S.fasta
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NR_023363.1&rettype=fasta&retmode=text" > 5S.fasta
