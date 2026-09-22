# QC Troubleshooting & Investigation 

## 1. Initial QC and Problem Detection

### 1.1 FastQC Summary (Raw Reads, Pre-trimming)

| Sample | Group | Total reads | GC% | Per-seq GC content | Overrepresented seq | Sequence Duplication |
| :---- | :---- | :---- | :---- | :---- | :---- | :---- |
| SRR15852393 | Tumor | 31457369 | 63-64 | Elevated secondary peak | 2.75%-2.39% | Failed |
| SRR15852394 | Tumor | 21474292 | 60 | Elevated | 3.13%-3.11% | Failed |
| SRR15852395 | Tumor | 22241864 | 71-72 | Sharp peak ~78% | 28.41%-27.59% | Failed |
| SRR15852423 | Normal | 35600052 | 44 | Bimodal; ~40–52% GC, deviates from theoretical. | 0.54%-0.73% | Failed |
| SRR15852424 | Normal | 32683367 | 50 | Normal | 1.31%-4.58% | Failed |
| SRR15852425 | Normal | 27839257 | 49-50 | Main peak ~47% GC; high-GC tail (~60–85%) | 0 | Pass |

### Observations

- Normal human RNA-Seq typically shows 45–55% GC content with a single, 
  unimodal peak. All three tumor samples deviate from this — 
  SRR15852393 and SRR15852395 show elevated overall GC with abnormal 
  secondary/sharp peaks, later confirmed as ribosomal RNA contamination 
  (see Section 2).
- SRR15852423, a normal sample, also shows an abnormal bimodal GC 
  distribution (~40–52%) — a distinct signature from the tumor samples, 
  later linked to genomic DNA contamination rather than rRNA (see 
  Section 4).
- Adapter Content failed for all six samples on raw reads. This reflects 
  expected read-through adapter signal due to insert sizes shorter than 
  the 150bp read length, and was resolved by adapter trimming with 
  fastp (see Section 2.3).
- SRR15852425 was the only sample to pass Sequence Duplication Levels 
  and showed 0% overrepresented sequences, making it the cleanest 
  sample in the raw dataset.

### 1.2 Initial STAR Alignment Results

| Sample | Input Reads | Unique Map % | Multi-Map % | Too Many Loci % | Unmapped (short) % | Mismatch Rate |
| :---- | :---- | :---- | :---- | :---- | :---- | :---- |
| SRR15852423 | 34,948,205 | 90.38% | 3.52% | 0.49% | 4.07% | 0.53% |
| SRR15852424 | 32,074,761 | 80.70% | 14.48% | 0.60% | 3.73% | 0.52% |
| SRR15852425 | 27,679,914 | 85.93% | 8.25% | 0.24% | 5.36% | 0.35% |
| SRR15852393 | 29,548,227 | 42.68% | 51.89% | 0.91% | 3.90% | 0.87% |
| SRR15852394 | 20,661,568 | 59.22% | 33.36% | 0.72% | 6.12% | 0.94% |
| SRR15852395 | 20,378,897 | 5.77% | 90.00% | 0.73% | 2.91% | 1.36% |

The three tumor samples showed markedly reduced unique mapping alongside 
elevated multi-mapping — consistent with the FastQC anomalies above — 
prompting the investigation detailed in the following sections.

## 2. rRNA Contamination Investigation

### 2.1 Ruling Out Reference Genome Mismatch

The first hypothesis considered for the abnormal mapping statistics 
(Section 1.2) was a reference genome or annotation mismatch — i.e., that 
the tumor samples had been aligned against a different or incorrect 
genome build than the normal samples.

This was ruled out directly: all six samples were confirmed to have been 
aligned using the identical STAR genome index 
(`~/rnaseq_project/star_index`, built from 
`Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa` and 
`Homo_sapiens.GRCh38.116.gtf`), verified via the `@PG` header embedded 
in each BAM file:

```bash
samtools view -H <bam_file> | grep "^@PG"
```

Since a genome/annotation mismatch would be expected to affect all 
samples equally, and only the three tumor samples showed degraded 
mapping while the three normal samples aligned well against the same 
index, this hypothesis was eliminated in favor of a sample-specific 
cause.

### 2.2 SortMeRNA — Testing Standard rRNA Contamination

Review of the original study's published methods revealed their 
pipeline included an explicit rRNA-filtering step (Bowtie2, before 
alignment) that this pipeline's fastp → STAR workflow did not initially 
replicate. Standard rRNA contamination was tested as a candidate cause 
using [SortMeRNA](https://github.com/sortmerna/sortmerna) (v4.3.4, 
default reference database) on SRR15852395, followed by realignment of 
the filtered reads with STAR.

| Metric | Original | After rRNA Filtering |
|---|---|---|
| Reads flagged as rRNA | — | 19.21% |
| Uniquely mapped | 5.77% | 6.89% |
| Multi-mapped | 90.00% | 89.29% |
| Splice junctions annotated | 9.9% | 10.9% |

**Result:** Removing ~19% of reads as rRNA shifted mapping metrics by 
under 1 percentage point — far too little to explain the 90% 
multi-mapping rate. Standard rRNA contamination, as captured by 
SortMeRNA's default database, was ruled out as the primary cause at 
this stage.

This negative result prompted a deeper investigation (Sections 2.4–2.6), 
which later identified the actual contaminants as rRNA precursor/spacer 
sequences not well represented in SortMeRNA's default reference — 
confirming rRNA was still the underlying cause, just not detectable 
with this tool's standard configuration.

**Why SortMeRNA missed it:** SortMeRNA's default reference database 
(`smr_v4.3_default_db.fasta`) is built from:
- SILVA 138 SSURef NR99 (16S, 18S)
- SILVA 132 LSURef (23S, 28S)
- RFAM v14.1 (5S, 5.8S)

Source: https://github.com/sortmerna/sortmerna/blob/master/README.md#databases

It does not cover the unprocessed **45S pre-ribosomal precursor 
transcript** or its spacer regions (5'ETS, ITS1, ITS2, 3'ETS) — the 
intermediate sequences produced before mature rRNA is cleaved out (see 
Section 2.6). Since the actual contaminant in this sample turned out to 
include substantial precursor/spacer material, most of it was invisible 
to this tool's default configuration, explaining why filtering had 
almost no effect despite the correct underlying mechanism.

### 2.3 Adapter Contamination Check (fastp) 
Fastp reports for all samples confirmed correct detection and trimming of standard Illumina TrueSeq adapters
with negligible adapter dimer rates. GC content increased after trimming in the tumor samples. Evidence against adapters as the source of their elevated GC content, since removing adapter-contaminated tails only concentrated the underlying contaminant further.

| Sample | Detected Adapter | Insert Size Peak | Duplication Rate | GC Before | GC After |
|---|---|---|---|---|---|
| SRR15852393 | TruSeq (correct) | 104bp | 24.08% | 64.2% | 67.7% |
| SRR15852394 | TruSeq (correct) | 105bp | 19.99% | 60.3% | 62.0% |
| SRR15852395 | TruSeq (correct) | 119bp | 43.53% | 72.2% | 78.7% |


### observations:
GC content after filtering confirms the raw FastQC finding across all six samples; tumor samples sit at 62:79% (elevated/abnormal), 
while normal samples cluster around 44:15 % (expected range for human RNA-seq).Trimming neither resolved nor caused this pattern
-Reads with adapters are notably higher in the tumor samples (83- 87%) than normal samples (42–70%) .consistent with the shorter
insert sizes identified in these samples (104–119bp vs. a 150bp read length), producing more read-through into the adapter. 
sequence. This is expected given fragment size, not a defect — fastp correctly identified and removed it Duplication rate
does not cleanly separate tumours from normal (e.g., SRR15852424, a normal sample, has the highest duplication rate of all six at 44.82%)
indicating duplication alone is not diagnostic for the contamination pattern under investigation here.
Conclusion: Adapter trimming performed correctly across all samples; adapter contamination was ruled out 
as the cause of the elevated GC content and poor mapping statistics in the tumor samples. 

### 2.4 Overrepresented Sequence Analysis 
FastQC's per-sample "Overrepresented Sequences" module was used to quantify how much of each library 
consisted of abnormally duplicated 50bp sequences, and to establish which samples were most affected. 
| Sample | # Overrepresented Sequences | % of Library |
|---|---|---|
| SRR15852393 | 19 | 2.75% |
| SRR15852394 | 16 | 3.13% |
| SRR15852395 | 119 | **27.6%** |

Sample SRR15852395 stood out sharply — over a quarter of its entire library consisted of overrepresented sequences,
an order of magnitude higher than the other two affected samples. This directly matched its alignment statistics
(Section 1.2): the sample with by far the highest overrepresented-sequence burden also had by far the worst unique
mapping rate (5.77%). 
All sequences returned "No Hit" against FastQC's built-in contaminant/ adapter list, meaning they did not match any 
of FastQC's small internal reference set — this does not mean the sequences have no biological origin, only that identifying 
them required a separate tool (BLAST; see Section 2.6). 

### 2.5 K-mer Comparison Across Samples

Initial comparison of overrepresented sequences between samples used 
exact-string matching, which showed limited overlap: 5 sequences shared 
between SRR15852393/394, 8 shared between SRR15852393/395, and 0 shared 
between SRR15852394/395. However, exact-string matching has a blind spot: 
FastQC reports fixed 50bp windows of any longer contaminating sequence, 
and different samples' most-duplicated windows can start at slightly 
different offsets along the same underlying molecule — producing strings 
that differ despite substantial real overlap.

To address this, each sample's overrepresented sequences were decomposed 
into overlapping 20-base substrings ("20-mers"), and the resulting sets 
were compared pairwise across samples 

| Comparison | Shared 20-mers |
|---|---|
| SRR15852393 & SRR15852394 | 90 |
| SRR15852393 & SRR15852395 | 129 |
| SRR15852394 & SRR15852395 | 0 |

This revealed two distinct, non-overlapping contaminant populations:
- **Population A** — shared between SRR15852393 and SRR15852394
- **Population B** — shared between SRR15852393 and SRR15852395

SRR15852393 carried sequences from both populations plus some unique to 
itself; SRR15852394 and SRR15852395 each carried only one population, 
and did not share any contaminant sequence with each other directly.

### 2.6 BLAST Identification (Population A & B)

Representative 50bp sequences from each population were submitted to 
NCBI BLAST (blastn, Nucleotide collection [nt] database, web interface) 
to identify their biological origin.

| Population | Shared Between | BLAST Identity | Identity / Coverage / E-value |
|---|---|---|---|
| A | 393 ↔ 394 | Mature human 28S ribosomal RNA | ~93.5% / 100% / 1e-15 |
| B | 393 ↔ 395 | Human 45S pre-ribosomal RNA precursor + rDNA spacer regions (RNA45SN1–N5, 5'ETS) | ~93.5% / 100% / 1e-15 |

Both populations returned confident, high-coverage hits (E-value 1e-15 
indicates the match is not attributable to chance; 100% query coverage 
indicates the entire 50bp query aligned). Hits spanned multiple primate 
species due to the high evolutionary conservation of rRNA sequences, but 
directly included Homo sapiens records in both cases.

Population A corresponds to **mature** rRNA — the finished product after 
processing. Population B corresponds to the **unprocessed 45S precursor 
and spacer regions** that are normally cleaved away during rRNA 
maturation (see Section 2.2 for why this explains SortMeRNA's earlier 
negative result — its default database targets mature rRNA sequences, 
not precursor/spacer regions).

### 2.7 Literature Cross-Reference

The original study's published Methods section (Identification of Five 
Cytotoxicity-Related Genes Involved in the Progression of Triple-Negative 
Breast Cancer, associated with GSE183947) was reviewed for confirmation. 
It states:

> "rRNA contamination was filtered by Bowtie2 ... prior to alignment 
> with TopHat."

This confirms the original authors anticipated residual rRNA as a 
routine risk for this dataset/protocol (Illumina Stranded Total RNA Prep 
with Ribo-Zero Plus depletion) and built a dedicated filtering step into 
their pipeline — rather than a rare or unexpected artifact. Ribo-Zero 
Plus depletion probes are designed primarily against mature rRNA 
sequences, which is consistent with Population B (precursor/spacer 
regions) being more likely to evade depletion than Population A (mature 
rRNA).

---

## 3. rRNA Remediation

### 3.1 Reference Sequence Retrieval

Reference sequences for the identified rRNA populations were retrieved 
directly from NCBI using the accession numbers returned by BLAST 
(Section 2.6):

| Accession | Description |
|---|---|
| NR_145819.1 | RNA45SN1 |
| NR_146144.1 | RNA45SN2 |
| NR_146151.1 | RNA45SN3 |
| NR_146117.1 | RNA45SN4 |
| NR_046235.3 | RNA45SN5 |

Mature 18S, 5.8S, 28S, and 5S rRNA sequences were also included for 
completeness. See 
[`scripts/06_download_rRNA_ref.sh`](../scripts/06_download_rRNA_ref.sh).

### 3.2 Bowtie2 Filtering

A Bowtie2 index was built from the combined reference set, and the three 
affected tumor samples were filtered against it, retaining only 
non-rRNA-mapping read pairs (`--un-conc`) for realignment. See 
[`scripts/07_rRNA_filtering.sh`](../scripts/07_rRNA_filtering.sh).

| Sample | Input Reads (trimmed) | Reads Remaining After rRNA Removal | % Removed as rRNA |
|---|---|---|---|
| SRR15852393 | ~29.5M | 15.97M | ~46% |
| SRR15852394 | ~20.7M | 16.00M | ~23% |
| SRR15852395 | ~20.4M | 1.61M | **~92%** |

SRR15852395's library consisted almost entirely of ribosomal RNA — over 
90% of its reads were removed as rRNA, an order of magnitude more than 
the other two affected samples.

### 3.3 Re-alignment Results (Before/After)

Filtered reads were realigned to the same STAR genome index used 
throughout. See 
[`scripts/08_star_realignment.sh`](../scripts/08_star_realignment.sh).

| Sample | Unique Mapping (Before) | Unique Mapping (After) | Multi-Mapping (Before) | Multi-Mapping (After) |
|---|---|---|---|---|
| SRR15852393 | 42.68% | **75.85%** | 51.89% | 14.95% |
| SRR15852394 | 59.22% | **75.92%** | 33.36% | 14.82% |
| SRR15852395 | 5.77% | 25.75% | 90.00% | 28.08% |

SRR15852393 and SRR15852394 improved to levels comparable with the 
unaffected normal samples (80–90%), confirming rRNA contamination as the 
primary cause of their original poor mapping. SRR15852395 improved but 
remained well below an acceptable threshold.

### 3.4 SRR15852395: Residual Issue & Exclusion

Despite removing ~92% of its library as rRNA, SRR15852395's re-aligned 
unique mapping rate (25.75%) remained far below the other samples, with 
35.21% of reads unmapped as "too short." This indicates a second, 
unresolved quality issue beyond rRNA contamination — most consistent 
with degraded input RNA (fragmented, low-integrity starting material), 
which produces short, uninformative fragments that no rRNA-filtering 
step can recover.

With only ~414,000 uniquely mapped reads remaining — roughly two orders 
of magnitude below typical RNA-seq depth requirements — this sample was 
judged unsuitable for reliable gene-level quantification and was 
**excluded from downstream differential expression analysis**.

---

## 4. Genomic DNA Contamination (SRR15852423)

### 4.1 Detection via featureCounts

Gene-level read counting (`featureCounts`, see 
[`scripts/11_featurecounts.sh`](../scripts/11_featurecounts.sh)) revealed 
unexpectedly low feature-assignment rates across all samples, with one 
normal sample standing out as a severe outlier:

| Sample | Group | Assigned Reads | Total Reads | % Assigned | % NoFeatures |
|---|---|---|---|---|---|
| SRR15852393 | Tumor | 3,782,047 | 21,198,928 | 17.8% | 36% |
| SRR15852394 | Tumor | 4,217,091 | 19,824,490 | 21.3% | 36% |
| **SRR15852423** | **Normal** | **3,449,391** | **35,705,025** | **9.7%** | **78%** |
| SRR15852424 | Normal | 9,850,438 | 52,498,458 | 18.8% | 26% |
| SRR15852425 | Normal | 9,969,414 | 33,579,700 | 29.7% | 36% |

Chromosome-naming consistency between the BAM files and GTF annotation 
was confirmed as identical (both use unprefixed contig names, e.g. `1`, 
`2`, `X`), ruling out an annotation-mismatch explanation. All samples 
were confirmed to have used the same STAR genome index via BAM `@PG` 
header metadata. Some elevated NoFeatures rate is expected for this 
Total RNA-seq protocol (captures unspliced/intronic signal, unlike 
polyA-selected libraries) — but SRR15852423's 78% was a clear outlier 
relative to the 26–36% range seen in the other five samples.

### 4.2 RSeQC Read Distribution Analysis

`read_distribution.py` (RSeQC) was used to assess where SRR15852423's 
reads were landing relative to annotated gene structure, compared 
directly against SRR15852424 (same pipeline, same STAR index, similar 
read depth).

| Region | SRR15852423 | SRR15852424 |
|---|---|---|
| CDS Exons | 2.5% | 27.9% |
| 5'UTR Exons | 3.3% | 8.5% |
| 3'UTR Exons | 4.9% | 11.6% |
| **All Exonic (combined)** | **~10.7%** | **~48.0%** |
| **Introns** | **78.8%** | **49.6%** |

SRR15852423 showed introns dominating almost 8-to-1 over exonic regions 
— a pattern inconsistent with SRR15852424's roughly even exonic/intronic 
split (itself consistent with normal Total RNA-seq, which captures some 
unspliced/nascent transcript alongside mature mRNA). This pattern — high 
unique mapping (90.38%, Section 1.2) combined with overwhelmingly 
intronic read placement — is a recognized signature of **genomic DNA 
contamination**: DNA fragments map confidently and uniquely to the 
genome (since they are the genome), but were never transcribed RNA and 
therefore do not respect exon/intron boundaries the way mature or 
even unspliced RNA transcripts statistically tend to.

### 4.3 Exclusion Rationale

Unlike rRNA contamination, genomic DNA contamination has no viable 
computational correction: gDNA and genuine intronic RNA signal cannot be 
distinguished by sequence alone, since they originate from the same 
reference genome. The most plausible explanation is incomplete DNase 
digestion during RNA extraction for this specific specimen — a known, 
sample-specific library-prep failure mode, not a pipeline error (all 
five other samples, including three processed identically, did not show 
this pattern).

**SRR15852423 was excluded from downstream differential expression 
analysis.**

---

## 5. Final Sample Set & Justification

| Sample | Group | Issue Identified | Outcome |
|---|---|---|---|
| SRR15852393 | Tumor | rRNA contamination (Populations A + B) |  Remediated — included |
| SRR15852394 | Tumor | rRNA contamination (Population A) |  Remediated — included |
| SRR15852395 | Tumor | rRNA contamination (Population B) + likely degraded RNA |  Partially remediated, residual issue unresolved — **excluded** |
| SRR15852423 | Normal | Genomic DNA contamination |  No computational fix available — **excluded** |
| SRR15852424 | Normal | None identified |  Included |
| SRR15852425 | Normal | None identified (highest raw QC quality of all six samples) |  Included |

**Final analysis set: 2 tumor (SRR15852393, SRR15852394) vs. 2 normal 
(SRR15852424, SRR15852425).**

This design is unbalanced relative to the original 3-vs-3 sampling, and 
statistically underpowered compared to a well-replicated study, but 
every included sample's gene-level counts can be trusted — a stronger 
basis for differential expression than including compromised samples 
purely to preserve group size.

---

