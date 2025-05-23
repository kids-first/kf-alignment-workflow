# Kids First Data Resource Center BWA-GATK Short Reads Alignment and HaplotypeCaller Workflow

<p align="center">
  <img src="./kids_first_logo.svg" alt="Kids First repository logo" width="660px" />
</p>

The Kids First Data Resource Center (KFDRC) BWA-GATK Short Reads Alignment and
GATK Haplotyper Workflow is a Common Workflow Language (CWL) implementation of
various software used to take reads generated by next generation sequencing
(NGS) technologies and use those reads to generate alignment and, optionally,
variant information.

This workflow is an all-in-one alignment workflow capable of handling any kind
of reads inputs: BAM inputs, PE reads and mates inputs, SE reads inputs, or
any combination of these. The workflow will naively attempt to process these
depending on what you tell it you have provided. The user informs the workflow
of which inputs to process using three boolean inputs: `run_bam_processing`,
`run_pe_reads_processing`, and `run_se_reads_processing`. Providing `true`
values for these as well their corresponding inputs will result in those inputs
being processed.

In addition to the core alignment functionality, this workflow is also capable
of the following:
- Performing Haplotype Calling to generate a gVCF as well as associated metrics
- Collecting Hybrid-Selection (HS) Sequencing Metrics
- Collecting Whole Genome Sequencing (WGS) Metrics
- Collecting Aggregate Sequencing Metrics: Alignment Summary, Insert Size, Sequencing Artifact, GC Bias, and Quality Score Distribution
- Collecting Sex Chromosome Metrics
- Collecting HLA Genotyping Data

## Pipeline Software and Versions

Below is a breakdown of the software used in the workflow. Please note that this
breakdown is manually updated and, as such, may fall out of date with our workflow.
For the most up to date versions of our software please refer to the Docker
images present in the workflow. A table of the images and their usage can be
found [here](./dockers_bwagatk_alignment.md).

| Step                       | KFDRC BWA-GATK                      |
|----------------------------|-------------------------------------|
| Bam to Read Group (RG) BAM | samtools split                      |
| RG Bam to Fastq            | biobambam2 bamtofastq               |
| Adapter Trimming           | cutadapt                            |
| Fastq to RG Bam            | bwa mem                             |
| Merge RG Bams              | sambamba merge                      |
| Mark Duplicates            | samblaster                          |
| BaseRecalibration          | GATK BaseRecalibrator               |
| ApplyRecalibration         | GATK ApplyBQSR                      |
| Gather Recalibrated BAMs   | Picard GatherBamFiles               |
| Bam to Cram                | samtools view                       |
| Metrics                    | Picard                              |
| Sex Metrics                | samtools idxstats                   |
| HLA Genotyping             | T1k                                 |
| Contamination Calculation  | VerifyBamID                         |
| gVCF Calling               | GATK HaplotypeCaller                |
| Gather VCFs                | Picard MergeVcfs                    |
| Metrics                    | Picard CollectVariantCallingMetrics |

- [biobambam2](https://github.com/gt1/biobambam2): [2.0.50](https://github.com/gt1/biobambam2/releases/tag/2.0.50-release-20160705161609)
- [bwa](https://github.com/lh3/bwa): [0.7.17-r1188](https://github.com/lh3/bwa/releases/tag/v0.7.17)
- [Cutadapt](https://github.com/marcelm/cutadapt): [4.6](https://github.com/marcelm/cutadapt/releases/tag/v4.5)
- [GATK](https://github.com/broadinstitute/gatk) Our workflow uses three versions of GATK:
   - HaplotypeCaller: [4.beta.1](https://github.com/broadinstitute/gatk/releases/tag/4.beta.1)
   - BaseRecalibration: [4.0.3.0](https://github.com/broadinstitute/gatk/releases/tag/4.0.3.0)
   - File Indexing: [4.1.7.0](https://github.com/broadinstitute/gatk/releases/tag/4.1.7.0)
- [Picard](https://github.com/broadinstitute/picard): [2.18.9](https://github.com/broadinstitute/picard/releases/tag/2.18.9)
- [Sambamba](https://github.com/biod/sambamba): [0.6.3](https://github.com/biod/sambamba/releases/tag/v0.6.3)
- [samblaster](https://github.com/GregoryFaust/samblaster): [0.1.24](https://github.com/GregoryFaust/samblaster/releases/tag/v.0.1.24)
- [Samtools](https://github.com/samtools/samtools):
   - idxstats, split: [1.9](https://github.com/samtools/samtools/releases/tag/1.9)
   - BAM to CRAM conversion: [1.8](https://github.com/samtools/samtools/releases/tag/1.8)
- [T1k](https://github.com/mourisl/T1K): [1.0.5](https://github.com/mourisl/T1K/releases/tag/v1.0.5)
- [VerifyBamID](https://github.com/Griffan/VerifyBamID): [1.0.2](https://github.com/Griffan/VerifyBamID/releases/tag/1.0.2)

### Alignment

The principle function of this pipeline is the realignment of short reads to a reference genome.

#### Inputing Reads

Read information are passed in through the following inputs:
```yaml
  input_bam_list: "List of input BAM/CRAM/SAM files"
  cram_reference: "If input_bam_list contains CRAM, provided the reference used to generate that CRAM here"
  input_pe_reads_list: "List of input R1 paired end FASTQ reads"
  input_pe_mates_list: "List of input R2 paired end FASTQ reads"
  input_pe_rgs_list: "List of RG strings to use in PE processing"
  input_se_reads_list: "List of input single end FASTQ reads"
  input_se_rgs_list: "List of RG strings to use in SE processing"
```

This workflow accepts reads in any of the of the following formats:
- Aligned BAM/CRAM/SAM
- Unaligned BAM/CRAM/SAM
- Paired End FASTQ
- Single End FASTQ

Additionally, these files must have appropriate read group information. For
aligned and unaligned BAM/CRAM/SAM files, we assume that information is
contained within the file header. If your files do not have read group (`@RG`)
header information, you **must** add that information to the file header for
the pipeline to work!

If the user provides CRAM inputs, they must also provide the reference that was
used to generate the CRAM file.

FASTQ files do not have headers; their header information must be provided by
the user at runtime. The inputs that the user provides are handed directly to
the bwa `-R` option. From bwa:
```
-R	Complete read group header line. '\t' can be used in STR and will be
        converted to a TAB in the output SAM. The read group ID will be attached to
        every read in the output. An example is '@RG\tID:foo\tSM:bar'. [null] 
```

If the user provides multiple single end FASTQs or multiple sets of paired end
FASTQs, they must keep the files and read group lines in the same order.
For example:
```
input_pe_reads_list:
  - sample1_R1.fq
  - sample2_R1.fq
  - sample3_R1.fq
input_pe_mates_list:
  - sample1_R2.fq
  - sample2_R2.fq
  - sample3_R2.fq
input_pe_rgs_list:
  - sample1_rg_line
  - sample2_rg_line
  - sample3_rg_line
``` 

##### Activating Reads Processing

Once the user has provided their reads, they must then choose which processing
the pipeline will perform. This choice is controlled by the following
parameters:
```yaml
    run_bam_processing: "BAM/CRAM/SAM processing will be run. Requires: input_bam_list"
    run_pe_reads_processing: "PE reads processing will be run. Requires: input_pe_reads_list, input_pe_mates_list, input_pe_rgs_list"
    run_se_reads_processing: "SE reads processing will be run. Requires: input_se_reads_list, input_se_rgs_list"
```

If the user provides BAM/CRAM/SAMs they should set `run_bam_processing` to true.
If the user provides paired end FASTQs, they should set `run_pe_reads_processing` to true.
If the user provides single end FASTQs, they should set `run_se_reads_processing` to true.

### Alignment Metrics

After alignment, the pipeline contains a number of optional metrics collection
steps that the user can enable. These tools can be enabled using the following
parameters:
```yaml
    run_hs_metrics: "HsMetrics will be collected. Only recommended for WXS inputs. Requires: wxs_bait_interval_list, wxs_target_interval_list"
    run_wgs_metrics: "WgsMetrics will be collected. Only recommended for WGS inputs. Requires: wgs_coverage_interval_list"
    run_agg_metrics: "AlignmentSummaryMetrics, GcBiasMetrics, InsertSizeMetrics, QualityScoreDistribution, and SequencingArtifactMetrics will be collected."
    run_sex_metrics: "idxstats will be collected and X/Y ratios calculated"
```

In all but the most frugal cases, we recommend running the agg(regate) and sex
metrics. These steps require no additional inputs.

HS and WGS Metrics, however, should only be enabled for appropriate inputs. If
the inputs are WGS, we recommend enabling WGS metrics. If the inputs are WXS,
we recommend enabling WXS metrics. Both of these metrics tools require
additional inputs. For WGS, the user must provide a
`wgs_coverage_interval_list`. For WXS, the user must provide both a
`wxs_bait_interval_list` and `wxs_target_interval_list`. While we provide a
`wgs_coverage_interval_list` with the workflow, the `wxs_bait_interval_list`
and `wxs_target_interval_list` are going to be unique to the sequencing
experiment used to generate the reads. These inputs will vary run to run.
Therefore, the user must provide these intervals. 

### Haplotype Calling

Following alignment, this workflow can also perform GATK haplotype calling to
generate a gVCF and metrics files. To generate the gVCF, set
`run_gvcf_processing` to `true` and provide the following optional files:
`dbsnp_vcf`, `contamination_sites_bed`, `contamination_sites_mu`,
`contamination_sites_ud`, `wgs_calling_interval_list`, and
`wgs_evaluation_interval_list`. 

These are the gVCF processing relevant inputs and descriptions:
```yaml
    dbsnp_vcf: "dbSNP vcf file"
    dbsnp_idx: "dbSNP vcf index file"
    contamination_sites_bed: ".bed file for markers used in this analysis,format(chr\tpos-1\tpos\trefAllele\taltAllele)"
    contamination_sites_mu: ".mu matrix file of genotype matrix"
    contamination_sites_ud: ".UD matrix file from SVD result of genotype matrix"
    wgs_calling_interval_list: "WGS interval list used to aid scattering Haplotype caller"
    wgs_evaluation_interval_list: "Target intervals to restrict gVCF metric analysis (for VariantCallingMetrics)"
    run_gvcf_processing: "gVCF will be generated. Requires: dbsnp_vcf, contamination_sites_bed, contamination_sites_mu, contamination_sites_ud, wgs_calling_interval_list, wgs_evaluation_interval_list"
```

### HLA Genotyping

This workflow can also collect HLA genotyping data. To read more on this
feature please see [our documentation](./T1K_README.md). This feature is
on by default but can be disabled by setting `run_t1k` to `false`. HLA
genotyping also requires the `hla_dna_ref_seqs` and `hla_dna_gene_coords`
inputs. The public app provides default files for these. If you have are using
a different reference genome, see the [T1k readme](https://github.com/mourisl/T1K?tab=readme-ov-file#install)
for instructions on creating these files.

## Outputs

Below are the complete list of the outputs that can be generated by the pipeline:
```yaml
  cram: "(Re)Aligned Reads File"
  gvcf: "Genomic VCF generated from the realigned alignment file."
  verifybamid_output: "Output from VerifyBamID that is used to calculate contamination."
  cutadapt_stats: "Stats from Cutadapt runs, if run. One or more per read group."
  bqsr_report: "Recalibration report from BQSR."
  gvcf_calling_metrics: "General metrics for gVCF calling quality."
  hs_metrics: "Picard CollectHsMetrics metrics for the analysis of target-capture sequencing experiments."
  wgs_metrics: "Picard CollectWgsMetrics metrics for evaluating the performance of whole genome sequencing experiments."
  alignment_metrics: "Picard CollectAlignmentSummaryMetrics high level metrics about the alignment of reads within a SAM/BAM file."
  gc_bias_detail: "Picard CollectGcBiasMetrics detailed metrics about reads that fall within windows of a certain GC bin on the reference genome."
  gc_bias_summary: "Picard CollectGcBiasMetrics high level metrics that capture how biased the coverage in a certain lane is."
  gc_bias_chart: "Picard CollectGcBiasMetrics plot of GC bias."
  insert_metrics: "Picard CollectInsertSizeMetrics metrics about the insert size distribution of a paired-end library."
  insert_plot: "Picard CollectInsertSizeMetrics insert size distribution plotted."
  artifact_bait_bias_detail_metrics: "Picard CollectSequencingArtifactMetrics bait bias artifacts broken down by context."
  artifact_bait_bias_summary_metrics: "Picard CollectSequencingArtifactMetrics summary analysis of a single bait bias artifact."
  artifact_error_summary_metrics: "Picard CollectSequencingArtifactMetrics summary metrics as a roll up of the context-specific error rates, to provide global error rates per type of base substitution."
  artifact_pre_adapter_detail_metrics: "Picard CollectSequencingArtifactMetrics pre-adapter artifacts broken down by context."
  artifact_pre_adapter_summary_metrics: "Picard CollectSequencingArtifactMetrics summary analysis of a single pre-adapter artifact."
  qual_metrics: "Quality metrics for the realigned CRAM."
  qual_chart: "Visualization of quality metrics."
  idxstats: "samtools idxstats of the realigned reads file."
  xy_ratio: "Text file containing X and Y reads statistics generated from idxstats."
  t1k_genotype_tsv: "HLA genotype results from T1k"
```

## Caveats:
- Duplicates are flagged in a process that is connected to bwa mem. The
  implication of this design decision is that duplicates are flagged only on the
  inputs of that are scattered into bwa. Duplicates, therefore, are not being
  flagged at a library level and, for large BAM and FASTQ inputs, duplicates are
  only being detected within a portion of the read group.

## Tips for running:
- For the FASTQ input file lists (PE or SE), make sure the lists are properly
  ordered. The items in the arrays are processed based on their position. These
  lists are dotproduct scattered. This means that the first file in
  `input_pe_reads_list` is run with the first file in `input_pe_mates_list` and
  the first string in `input_pe_rgs_list`. This also means these arrays must be
  the same length or the workflow will fail.
- The input for the `reference_tar` must be a tar file containing the
  reference fasta along with its indexes. The required indexes are
  `[.64.ann,.64.amb,.64.bwt,.64.pac,.64.sa,.dict,.fai]` and are generated by bwa,
  Picard, and Samtools. Additionally, an `.64.alt` index is recommended. The
  following is an example of a complete reference tar input:
```
~ tar tf Homo_sapiens_assembly38.tgz
Homo_sapiens_assembly38.dict
Homo_sapiens_assembly38.fasta
Homo_sapiens_assembly38.fasta.64.alt
Homo_sapiens_assembly38.fasta.64.amb
Homo_sapiens_assembly38.fasta.64.ann
Homo_sapiens_assembly38.fasta.64.bwt
Homo_sapiens_assembly38.fasta.64.pac
Homo_sapiens_assembly38.fasta.64.sa
Homo_sapiens_assembly38.fasta.fai
```
- If you are making your own bwa indexes make sure to use the `-6` flag to
  obtain the `.64` version of the indexes. Indexes that do not match this naming
  schema will cause a failure in certain runner ecosystems.
- Should you decide to create your own reference indexes and omit the ALT
  index file from the reference, or if its naming structure mismatches the other
  indexes, then your alignments will be equivalent to the results you would
  obtain if you run BWA-MEM with the `-j` option.
- For advanced usage, users can skip the knownsite indexing by providing the
  `knownsites_indexes` input.  This file list should contain the indexes for each
  of the files in your knownsites input. Please note this list must be ordered in
  such a way where the position of the index file in the `knownsites_indexes`
  list must correspond with the position of the VCF file in the knownsites list
  that it indexes. Failure to order in this way will result in the pipeline
  failing or generating erroneous files.
- For large BAM inputs, users may encounter a scenario where jobs fail during
  the bamtofastq step. The given error will recommend that users try increasing
  disk space. Increasing the disk space will solve the error for all but the
  largest inputs. For those extremely large inputs with many read groups that
  continue to get this error, it is recommended that users increase the value for
  `bamtofastq_cpu`. Increasing this value will decrease the number of concurrent
  bamtofastq jobs that run on the same instance.

## Basic Info
- [D3b dockerfiles](https://github.com/d3b-center/bixtools)
- Testing Tools:
   - [CAVATICA Platform](https://cavatica.sbgenomics.com/)
   - [Common Workflow Language reference implementation (cwltool)](https://github.com/common-workflow-language/cwltool/)

## References
- KFDRC AWS S3 bucket: s3://kids-first-seq-data/broad-references/
- CAVATICA: https://cavatica.sbgenomics.com/u/kfdrc-harmonization/kf-references/
- Broad Institute Goolge Cloud: https://console.cloud.google.com/storage/browser/gcp-public-data--broad-references/hg38/v0
