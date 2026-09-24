# RNA-Seq Differential expression analysis-Triple-Negative Breast Cancer

## Analysis of paired RNA-Seq data to Identify differential expressed genes in Triple-Negative Breast Cancer (TNBC) based on the public dataset (GSE183947 )

Raw Data available at 
https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE183947

## Summary
This project analyzes RNA-Seq data from six samples (Tumor sample and three normal samples)from the public dataset [GSE183947][https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE183947]
 processed through a standard pipeline[QC-trimming-alignment-counting- differential expression]                                                                                                                       
 During initial QC, four samples showed evidence of contamination: three tumor samples showed unique mapping rates as low as 5.77–59.22% (vs. 80–90% in unaffected samples) later identified via FASTQ, BLAST and cross-refering the original study's method as ribosomal RNA contamination. A separate normal sample showed abnormally low gene-level read assignment, identified via RSEQC as genomic DNA contamination. rRNA filtering successfully recovered two of the three affected tumor samples to normal mapping rates; the third only showed partial recovery, indicating an additional, unresolved RNA quality issue. Genomic DNA contamination had no viable computational fix Tow samples were excluded from downstream analysis as a result Differential expression analysis was performed on the remaining 
2 tumor vs 2 normal see   QC_troubleeshoting.md for full investigation 

## Respiratory Structure
--bash
├── scripts/
│ ├── 00_download_extract.sh
│ ├── 01_qc_raw.sh
│ ├── 02_trimming.sh
│ ├── 03_star_index_alignment.sh
│ ├── 04_extract_overrep_seqs.py
│ ├── 05_download_rRNA_ref.sh
│ ├── 06_rRNA_filtering.sh
│ ├── 07_star_realignment.sh
│ ├── 08_bam_indexing.sh
│ ├── 09_strandedness_check.sh
│ ├── 10_featurecounts.sh
│ ├── 11_read_distribution.sh
│ └── 12_deseq2_analysis.R
├── results/
│ ├── multiqc_report_raw.html
│ ├── multiqc_report_fastp.html
│ ├── mapping_stats_initial.csv
│ ├── mapping_stats_rRNA_filtered.csv
│ ├── featurecounts_summary.txt
│ ├── read_distribution_423_vs_424.csv
│ └── DESeq2_Tumor_vs_Normal.csv
├── docs/
│ └── QC_troubleshooting.md
└── README.md
'''















