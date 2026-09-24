# RNA-Seq Differential expression analysis-Triple-Negative Breast Cancer

## Analysis of paired RNA-Seq data to Identify differential expressed genes in Triple-Negative Breast Cancer (TNBC) based on the public dataset (GSE183947 )

Raw Data available at 
https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE183947

## Summary
This project analyzes RNA-Seq data from six samples (Tumor sample and three normal samples)from the public dataset [GSE183947][https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE183947]
 processed through a standard pipeline[QC-trimming-alignment-counting- differential expression]                                                                                                                       
 During initial QC, four samples showed evidence of contamination: three tumor samples showed unique mapping rates as low as 5.77–59.22% (vs. 80–90% in unaffected samples) later identified via FASTQ, BLAST and cross-refering the original study's method as ribosomal RNA contamination. A separate normal sample showed abnormally low gene-level read assignment, identified via RSEQC as genomic DNA contamination. rRNA filtering successfully recovered two of the three affected tumor samples to normal mapping rates; the third only showed partial recovery, indicating an additional, unresolved RNA quality issue. Genomic DNA contamination had no viable computational fix Tow samples were excluded from downstream analysis as a result Differential expression analysis was performed on the remaining 
2 tumor vs 2 normal 
see   QC_troubleeshoting.md for full investigation Full diagnostic detail is documented in 
[`QC_troubleshooting.md`](QC_troubleshooting.md).
## Dataset

- **Source:** [GSE183947](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE183947)
- **Paper:** Identification of Five Cytotoxicity-Related Genes Involved 
  in the Progression of Triple-Negative Breast Cancer
- **Samples:** 6 paired tumor/normal fresh surgical tissue specimens
- **Library prep:** Illumina Stranded Total RNA Prep with Ribo-Zero Plus 
  (rRNA + globin depletion)
- **Reference:** GRCh38, Ensembl annotation v116
  
## Respiratory Structure

```
├── scripts/
│   ├── 00_download_extract.sh
│   ├── 01_qc_raw.sh
│   ├── 02_trimming.sh
│   ├── 03_star_index_alignment.sh
│   ├── 04_extract_overrep_seqs.py
│   ├── 05_download_rRNA_ref.sh
│   ├── 06_rRNA_filtering.sh
│   ├── 07_star_realignment.sh
│   ├── 08_bam_indexing.sh
│   ├── 09_strandedness_check.sh
│   ├── 10_featurecounts.sh
│   ├── 11_read_distribution.sh
│   └── 12_deseq2_analysis.R
├── results/
│   ├── multiqc_report_raw.html
│   ├── multiqc_report_fastp.html
│   ├── mapping_stats_initial.csv
│   ├── mapping_stats_rRNA_filtered.csv
│   ├── featurecounts_summary.txt
│   ├── read_distribution_423_vs_424.csv
│   └── DESeq2_Tumor_vs_Normal.csv
├── docs/
│   └── QC_troubleshooting.md
└── README.md
```

## Requirements

- SRA Toolkit (prefetch, fasterq-dump)
- fastp v1.3.6
- FastQC / MultiQC 0.12.1
- STAR (2.7.11b)
- samtools
- SortMeRNA (v4.3.4)
- Bowtie2
- RSeQC
- subread (featureCounts)
- R (DESeq2, apeglm)
```
## Sample Summary
| Sample | Group | Status |
|---|---|---|
| SRR15852393 | Tumor |  Included  |
| SRR15852394 | Tumor |  Included  |
| SRR15852395 | Tumor |  Excluded  |
| SRR15852423 | Normal |  Excluded |
| SRR15852424 | Normal |  Included |
| SRR15852425 | Normal |  Included |

**Final analysis set:** 2 tumor vs. 2 normal.
```
## Pipeline

### 1. Data Download & Extraction
```bash
bash scripts/00_download_extract.sh
```
Downloaded raw SRA files using `prefetch`, extracted to paired-end FASTQ 
with `fasterq-dump`.

### 2. Quality Control (Raw Reads)
```bash
bash scripts/01_qc_raw.sh
```
FastQC + MultiQC on raw reads. Revealed abnormal GC content and 
overrepresented sequences in the tumor samples — see 
[QC troubleshooting §1.1](QC_troubleshooting.md#11-fastqc-summary-raw-reads-pre-trimming).

### 3. Adapter & Quality Trimming
```bash
bash scripts/02_trimming.sh
```
fastp (Q20, min length 36). See 
[QC troubleshooting §2.3](QC_troubleshooting.md#23-adapter-contamination-check-fastp).

### 4. STAR Genome Index & Initial Alignment
```bash
bash scripts/03_star_index_alignment.sh
```
```
**Result:** Tumor samples showed unique mapping as low as 5.77–59.22% vs. 
80–90% in normal samples — see 
[QC troubleshooting §1.2](QC_troubleshooting.md#12-initial-star-alignment-results).

### 5–6. rRNA Contamination: Detection
```bash
python scripts/04_extract_overrep_seqs.py
bash scripts/05_download_rRNA_ref.sh
```
Identified two rRNA populations (mature 28S; 45S precursor/spacer 
regions) via FastQC overrepresented-sequence analysis, k-mer comparison, 
and BLAST — see 
[QC troubleshooting §2.4–2.7](docs/QC_troubleshooting.md#24-overrepresented-sequence-analysis).

### 7. rRNA Filtering & Re-alignment
```bash
bash scripts/06_rRNA_filtering.sh
bash scripts/07_star_realignment.sh
```
**Result:** Unique mapping improved to 75.85% (SRR15852393) and 75.92% 
(SRR15852394). SRR15852395 improved only to 25.75% — excluded. See 
[QC troubleshooting §3](QC_troubleshooting.md#3-rrna-remediation).

### 8. BAM Indexing
```bash
bash scripts/08_bam_indexing.sh
```

### 9. Strandedness Check
```bash
bash scripts/09_strandedness_check.sh
```
**Result:** Library confirmed unstranded (~43%/43% split) → `-s 0` used 
in featureCounts.

### 10. Gene-Level Counting
```bash
bash scripts/10_featurecounts.sh
```
**Result:** SRR15852423 showed only 9.7% feature-assignment — prompted 
further investigation.

### 11. Genomic DNA Contamination Check
```bash
bash scripts/11_read_distribution.sh
```
**Result:** SRR15852423 showed 78.8% intronic reads vs. 49.6% in matched 
sample SRR15852424 — confirmed genomic DNA contamination,  — excluded. See 
[QC troubleshooting §4](QC_troubleshooting.md#4-genomic-dna-contamination-srr15852423).

---

## Results Summary

| Sample | Group | Initial Unique Mapping | Final Unique Mapping | Outcome |
|---|---|---|---|---|
| SRR15852393 | Tumor | 42.68% | 75.85% |  Included |
| SRR15852394 | Tumor | 59.22% | 75.92% |  Included |
| SRR15852395 | Tumor | 5.77% | 25.75% |  Excluded |
| SRR15852423 | Normal | 90.38% | — |  Excluded  |
| SRR15852424 | Normal | 80.70% | — |  Included |
| SRR15852425 | Normal | 85.93% | — |  Included |

```
## References

- Dataset: [GSE183947](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE183947)
- Original paper: Identification of Five Cytotoxicity-Related Genes 
  Involved in the Progression of Triple-Negative Breast Cancer
- SortMeRNA: https://github.com/sortmerna/sortmerna









