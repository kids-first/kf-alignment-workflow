# Kids First Data Resource Center Alignment and GATK HaplotypeCaller Workflows

![data service logo](https://github.com/d3b-center/d3b-research-workflows/raw/master/doc/kfdrc-logo-sm.png)

The Kids First Data Resource Center Alignment and Haplotype Calling Workflow (bam/fastq-to-cram, gVCF optional) follows
Broad best practices outlined in [Data pre-processing for variant discovery.](https://gatk.broadinstitute.org/hc/en-us/articles/360035535912-Data-pre-processing-for-variant-discovery)
It uses bam/fastq input and aligns/re-aligns to a bwa-indexed reference fasta, version hg38. Resultant bam is de-dupped and
base score recalibrated. Contamination is calculated and a gVCF is created optionally using GATK4 vbeta.1-3.5 HaplotypeCaller. Inputs from
this can be used later on for further analysis in joint trio genotyping and subsequent refinement and deNovo variant analysis. If you would like to run this workflow using the cavatica public app, a basic primer on running public apps can be found [here](https://www.notion.so/d3b/Starting-From-Scratch-Running-Cavatica-af5ebb78c38a4f3190e32e67b4ce12bb).
 Alternatively, if you'd like to run it locally using `cwltool`, a basic primer on that can be found [here](https://www.notion.so/d3b/Starting-From-Scratch-Running-CWLtool-b8dbbde2dc7742e4aff290b0a878344d) and combined with app-specific info from the readme below.
 This workflow is the current production workflow, equivalent to this [Cavatica public app](https://cavatica.sbgenomics.com/public/apps#cavatica/apps-publisher/kfdrc-alignment-workflow) and supersedes the [old workflow](https://github.com/kids-first/kf-alignment-workflow/tree/1.0.0) and [public app](https://cavatica.sbgenomics.com/public/apps#kids-first-drc/kids-first-drc-alignment-workflow/kfdrc-alignment-bam2cram2gvcf/); however outputs are considered equivalent.

## Input Agnostic Alignment Workflow
Workflow for the alignment or realignment of input SAMs/BAMs/CRAMs (Alignment/Map files, or AMs), PE reads, and/or SE reads; conditionally generate gVCF and metrics.

This workflow is a all-in-one workflow for handling any kind of reads inputs: BAM inputs, PE reads
and mates inputs, SE reads inputs,  or any combination of these. The workflow will naively attempt
to process these depending on what you tell it you have provided. The user informs the workflow of
which inputs to process using three boolean inputs: `run_bam_processing`, `run_pe_reads_processing`,
and `run_se_reads_processing`. Providing `true` values for these as well their corresponding inputs
will result in those inputs being processed.

The second half of the workflow deals with optional gVCF creation and metrics collection.
This workflow is capable of collecting the metrics using the following boolean flags: `run_hs_metrics`,
`run_wgs_metrics`, and `run_agg_metrics`. To run these metrics, additional optional inputs must
also be provided: `wxs_bait_interval_list` and `wxs_target_interval_list` for HsMetrics,
`wgs_coverage_interval_list` for WgsMetrics. To generate the gVCF, set `run_gvcf_processing` to
`true` and provide the following optional files: `dbsnp_vcf`, `contamination_sites_bed`,
`contamination_sites_mu`, `contamination_sites_ud`, `wgs_calling_interval_list`, and
`wgs_evaluation_interval_list`. Additionally, the workflow is capable of performing a basic
evaluation of the X and Y sex chromosomes using idxstats. To activate this feature, set `run_sex_metrics`
to `true`; no additonal inputs are required.



### Basic Info
- dockerfiles: https://github.com/d3b-center/bixtools
- tested with
  - Seven Bridges Cavatica Platform: https://cavatica.sbgenomics.com/
  - cwltool: https://github.com/common-workflow-language/cwltool/releases/tag/3.0.20200324120055

### References:
- https://console.cloud.google.com/storage/browser/broad-references/hg38/v0/
- kfdrc bucket: s3://kids-first-seq-data/broad-references/
- cavatica: https://cavatica.sbgenomics.com/u/kfdrc-harmonization/kf-references/

### Inputs:
```yaml
  # REQUIRED
  reference_tar: { type: File, doc: "Tar file containing a reference fasta and, optionally, its complete set of associated indexes (samtools, bwa, and picard)" }
  biospecimen_name: { type: string, doc: "String name of biospcimen" }
  output_basename: { type: string, doc: "String to use as the base for output filenames" }
  knownsites: { type: 'File[]', doc: "List of files containing known polymorphic sites used to exclude regions around known polymorphisms from analysis" }
  knownsites_indexes: { type: 'File[]?', doc: "Corresponding indexes for the knownsites. File position in list must match with its corresponding VCF's position in the knownsites file list. For example, if the first file in the knownsites list is 1000G_omni2.5.hg38.vcf.gz then the first item in this list must be 1000G_omni2.5.hg38.vcf.gz.tbi. Optional, but will save time/cost on indexing." }
  # REQUIRED for gVCF
  dbsnp_vcf: { type: 'File?', doc: "dbSNP vcf file" }
  dbsnp_idx: { type: 'File?', doc: "dbSNP vcf index file" }
  contamination_sites_bed: { type: 'File?', doc: ".bed file for markers used in this analysis,format(chr\tpos-1\tpos\trefAllele\taltAllele)" }
  contamination_sites_mu: { type: 'File?', doc: ".mu matrix file of genotype matrix" }
  contamination_sites_ud: { type: 'File?', doc: ".UD matrix file from SVD result of genotype matrix" }
  run_gvcf_processing: { type: boolean, doc: "gVCF will be generated. Requires: dbsnp_vcf, contamination_sites_bed, contamination_sites_mu, contamination_sites_ud, wgs_calling_interval_list, wgs_evaluation_interval_list" }
  # ADJUST TO FIT INPUT READS TYPE(S)
  input_bam_list: { type: 'File[]?', doc: "List of input BAM files" }
  input_pe_reads_list: { type: 'File[]?', doc: "List of input R1 paired end fastq reads" }
  input_pe_mates_list: { type: 'File[]?', doc: "List of input R2 paired end fastq reads" }
  input_pe_rgs_list: { type: 'string[]?', doc: "List of RG strings to use in PE processing" }
  input_se_reads_list: { type: 'File[]?', doc: "List of input single end fastq reads" }
  input_se_rgs_list: { type: 'string[]?', doc: "List of RG strings to use in SE processing" }
  run_bam_processing: { type: boolean, doc: "BAM processing will be run. Requires: input_bam_list" }
  run_pe_reads_processing: { type: boolean, doc: "PE reads processing will be run. Requires: input_pe_reads_list, input_pe_mates_list, input_pe_rgs_list" }
  cram_reference: { type: 'File?', doc: "If aligning from cram, need to provided reference used to generate that cram" }
  run_se_reads_processing: { type: boolean, doc: "SE reads processing will be run. Requires: input_se_reads_list, input_se_rgs_list" }
  # IF WGS or CREATE gVCF
  wgs_calling_interval_list: { type: 'File?', doc: "WGS interval list used to aid scattering Haplotype caller" }
  wgs_coverage_interval_list: { type: 'File?', doc: "An interval list file that contains the positions to restrict the wgs metrics assessment" }
  wgs_evaluation_interval_list: { type: 'File?', doc: "Target intervals to restrict gVCF metric analysis (for VariantCallingMetrics)" }
  # IF WXS
  wxs_bait_interval_list: { type: 'File?', doc: "An interval list file that contains the locations of the WXS baits used (for HsMetrics)" }
  wxs_target_interval_list: { type: 'File?', doc: "An interval list file that contains the locations of the WXS targets (for HsMetrics)" }
  # ADJUST TO GENERATE METRICS
  run_hs_metrics: { type: boolean, doc: "HsMetrics will be collected. Only recommended for WXS inputs. Requires: wxs_bait_interval_list, wxs_target_interval_list" }
  run_wgs_metrics: { type: boolean, doc: "WgsMetrics will be collected. Only recommended for WGS inputs. Requires: wgs_coverage_interval_list" }
  run_agg_metrics: { type: boolean, doc: "AlignmentSummaryMetrics, GcBiasMetrics, InsertSizeMetrics, QualityScoreDistribution, and SequencingArtifactMetrics will be collected. Recommended for both WXS and WGS inputs." }
  run_sex_metrics: {type: boolean, doc: "idxstats will be collected and X/Y ratios calculated"}
  # ADVANCED
  min_alignment_score: { type: 'int?', default: 30, doc: "For BWA MEM, Don't output alignment with score lower than INT. This option only affects output." }
  bamtofastq_cpu: { type: 'int?', doc: "CPUs to allocate to bamtofastq" }
```

### Outputs:
```yaml
  cram: {type: File, outputSource: samtools_bam_to_cram/output, doc: "(Re)Aligned Reads File"}
  gvcf: {type: 'File[]?', outputSource: generate_gvcf/gvcf, doc: "Genomic VCF generated from the realigned alignment file."}
  verifybamid_output: {type: 'File[]?', outputSource: generate_gvcf/verifybamid_output, doc: "Ouput from VerifyBamID that is used to calculate contamination."}
  bqsr_report: {type: File, outputSource: gatk_gatherbqsrreports/output, doc: "Recalibration report from BQSR."}
  gvcf_calling_metrics: {type: ['null', {type: array, items: {type: array, items: File}}], outputSource: generate_gvcf/gvcf_calling_metrics, doc: "General metrics for gVCF calling quality."}
  hs_metrics: {type: 'File[]?', outputSource: picard_collecthsmetrics/output, doc: "Picard CollectHsMetrics metrics for the analysis of target-capture sequencing experiments."}
  wgs_metrics: {type: 'File[]?', outputSource: picard_collectwgsmetrics/output, doc: "Picard CollectWgsMetrics metrics for evaluating the performance of whole genome sequencing experiments."}
  alignment_metrics: {type: 'File[]?', outputSource: picard_collectalignmentsummarymetrics/output, doc: "Picard CollectAlignmentSummaryMetrics high level metrics about the alignment of reads within a SAM file."}
  gc_bias_detail: {type: 'File[]?', outputSource: picard_collectgcbiasmetrics/detail, doc: "Picard CollectGcBiasMetrics detailed metrics about reads that fall within windows of a certain GC bin on the reference genome."}
  gc_bias_summary: {type: 'File[]?', outputSource: picard_collectgcbiasmetrics/summary, doc: "Picard CollectGcBiasMetrics high level metrics that capture how biased the coverage in a certain lane is."}
  gc_bias_chart: {type: 'File[]?', outputSource: picard_collectgcbiasmetrics/chart, doc: "Picard CollectGcBiasMetrics plot of GC bias."}
  insert_metrics: {type: 'File[]?', outputSource: picard_collectinsertsizemetrics/metrics, doc: "Picard CollectInsertSizeMetrics metrics about the insert size distribution of a paired-end library."}
  insert_plot: {type: 'File[]?', outputSource: picard_collectinsertsizemetrics/plot, doc: "Picard CollectInsertSizeMetrics insert size distribution plotted."}
  artifact_bait_bias_detail_metrics: {type: 'File[]?', outputSource: picard_collectsequencingartifactmetrics/bait_bias_detail_metrics, doc: "Picard CollectSequencingArtifactMetrics bait bias artifacts broken down by context."}
  artifact_bait_bias_summary_metrics: {type: 'File[]?', outputSource: picard_collectsequencingartifactmetrics/bait_bias_summary_metrics, doc: "Picard CollectSequencingArtifactMetrics summary analysis of a single bait bias artifact."}
  artifact_error_summary_metrics: {type: 'File[]?', outputSource: picard_collectsequencingartifactmetrics/error_summary_metrics, doc: "Picard CollectSequencingArtifactMetrics summary metrics as a roll up of the context-specific error rates, to provide global error rates per type of base substitution."}
  artifact_pre_adapter_detail_metrics: {type: 'File[]?', outputSource: picard_collectsequencingartifactmetrics/pre_adapter_detail_metrics, doc: "Picard CollectSequencingArtifactMetrics pre-adapter artifacts broken down by context."}
  artifact_pre_adapter_summary_metrics: {type: 'File[]?', outputSource: picard_collectsequencingartifactmetrics/pre_adapter_summary_metrics, doc: "Picard CollectSequencingArtifactMetrics summary analysis of a single pre-adapter artifact."}
  qual_metrics: {type: 'File[]?', outputSource: picard_qualityscoredistribution/metrics, doc: "Quality metrics for the realigned CRAM."}
  qual_chart: {type: 'File[]?', outputSource: picard_qualityscoredistribution/chart, doc: "Visualization of quality metrics."}
  idxstats: {type: 'File?', outputSource: samtools_idxstats_xy_ratio/output, doc: "samtools idxstats of the realigned BAM file."}
  xy_ratio: {type: 'File?', outputSource: samtools_idxstats_xy_ratio/ratio, doc: "Text file containing X and Y reads statistics generated from idxstats."}
```

#### Detailed Input Information:
The pipeline is build to handle three distinct input types:
1. SAMs/BAMs/CRAMs (Alignment/Map files, or AMs)
1. PE Fastqs
1. SE Fastqs

Additionally, the workflow supports these three in any combination. You can have PE Fastqs and AMs,
PE Fastqs and SE Fastqs, AMs and PE Fastqs and SE Fastqs, etc. Each of these three classes will be
procsessed and aligned separately and the resulting BWA aligned bams will be merged into a final BAM
before performing steps like BQSR and Metrics collection.

#####  Alignment/Map Inputs
The Alignment/Map processing portion of the pipeline is the simplest when it comes to inputs. You may provide
a single Alignment/Map file or many AMs. The input for AMs is a file list. In Cavatica or other GUI interfaces,
simply select the files you wish to process. For command line interfaces such as cwltool, your input
should look like the following.
```json
{
  ...,
  "run_pe_reads_processing": false,
  "run_se_reads_processing": false,
  "run_bam_processing": true,
  "input_bam_list": [
    {
      "class": "File",
      "location": "/path/to/bam1.bam"
    },
    {
      "class": "File",
      "location": "/path/to/bam2.bam"
    }
  ],
  ...
}
```

##### SE Fastq Inputs
SE fastq processing requires more input to build the jobs correctly. Rather than providing a single
list you must provide two lists: `input_se_reads_list` and `input_se_rgs_list`. The `input_se_reads_list`
is where you put the files and the `input_se_rgs_list` is where you put your desired BAM @RG headers for
each reads file. These two lists are must be ordered and of equal length. By ordered, that means the
first item of the `input_se_rgs_list` will be used when aligning the first item of the `input_se_reads_list`.
IMPORTANT NOTE: When you are entering the rg names, you need to use a second escape `\` to the tab values `\t`
as seen below. When the string value is read in by a tool such as cwltool it will interpret a `\\t` input
as `\t` and a `\t` as the literal `<tab>` value which is not a valid entry for bwa mem.
If you are using Cavatica GUI, however, no extra escape is necessary. The GUI will add an extra
escape to any tab values you enter.

In Cavatica make sure to double check that everything is in the right order when you enter the inputs.
In command line interfaces such as cwltool, your input should look like the following.
```json
{
  ...,
  "run_pe_reads_processing": false,
  "run_se_reads_processing": true,
  "run_bam_processing": false,
  "input_se_reads_list": [
    {
      "class": "File",
      "location": "/path/to/single1.fastq"
    },
    {
      "class": "File",
      "location": "/path/to/single2.fastq"
    }
  ],
  "inputs_se_rgs_list": [
    "@RG\\tID:single1\\tLB:library_name\\tPL:ILLUMINA\\tSM:sample_name",
    "@RG\\tID:single2\\tLB:library_name\\tPL:ILLUMINA\\tSM:sample_name"
  ],
  ...
}
```
Take particular note of how the first item in the rgs list is the metadata for the first item in the fastq list.

##### PE Fastq Inputs
PE Fastq processing inputs is exactly like SE Fastq processing but requires you to provide the paired mates
files for your input paired reads. Once again, when using Cavatica make sure your inputs are in the correct
order. In command line interfaces such as cwltool, your input should look like the following.
```json
{
  ...,
  "run_pe_reads_processing": true,
  "run_se_reads_processing": false,
  "run_bam_processing": false,
  "input_pe_reads_list": [
    {
      "class": "File",
      "location": "/path/to/sample1_R1.fastq"
    },
    {
      "class": "File",
      "location": "/path/to/sample2_R1fastq"
    },
    {
      "class": "File",
      "location": "/path/to/sample3_R1.fastq"
    }
  ],
  "input_pe_mates_list": [
    {
      "class": "File",
      "location": "/path/to/sample1_R2.fastq"
    },
    {
      "class": "File",
      "location": "/path/to/sample2_R2.fastq"
    },
    {
      "class": "File",
      "location": "/path/to/sample3_R2.fastq"
    }
  ],
  "inputs_pe_rgs_list": [
    "@RG\\tID:sample1\\tLB:library_name\\tPL:ILLUMINA\tSM:sample_name",
    "@RG\\tID:sample2\\tLB:library_name\\tPL:ILLUMINA\tSM:sample_name",
    "@RG\\tID:sample3\\tLB:library_name\\tPL:ILLUMINA\tSM:sample_name"
  ],
  ...
}
```

##### Multiple Input Types
As mentioned above, these three input types can be added in any combination. If you wanted to add
all three your command line input would look like the following.
```json
{
  ...,
  "run_pe_reads_processing": true,
  "run_se_reads_processing": true,
  "run_bam_processing": true,
  "input_bam_list": [
    {
      "class": "File",
      "location": "/path/to/bam1.bam"
    },
    {
      "class": "File",
      "location": "/path/to/bam2.bam"
    }
  ],
  "input_se_reads_list": [
    {
      "class": "File",
      "location": "/path/to/single1.fastq"
    },
    {
      "class": "File",
      "location": "/path/to/single2.fastq"
    }
  ],
  "inputs_se_rgs_list": [
    "@RG\\tID:single1\\tLB:library_name\\tPL:ILLUMINA\\tSM:sample_name",
    "@RG\\tID:single2\\tLB:library_name\\tPL:ILLUMINA\\tSM:sample_name"
  ],
  "input_pe_reads_list": [
    {
      "class": "File",
      "location": "/path/to/sample1_R1.fastq"
    },
    {
      "class": "File",
      "location": "/path/to/sample2_R1fastq"
    },
    {
      "class": "File",
      "location": "/path/to/sample3_R1.fastq"
    }
  ],
  "input_pe_mates_list": [
    {
      "class": "File",
      "location": "/path/to/sample1_R2.fastq"
    },
    {
      "class": "File",
      "location": "/path/to/sample2_R2.fastq"
    },
    {
      "class": "File",
      "location": "/path/to/sample3_R2.fastq"
    }
  ],
  "inputs_pe_rgs_list": [
    "@RG\\tID:sample1\\tLB:library_name\\tPL:ILLUMINA\\tSM:sample_name",
    "@RG\\tID:sample2\\tLB:library_name\\tPL:ILLUMINA\\tSM:sample_name",
    "@RG\\tID:sample3\\tLB:library_name\\tPL:ILLUMINA\\tSM:sample_name"
  ],
  ...
}
```

#### Example Runtimes:
1. 120 GB WGS BAM with AggMetrics, WgsMetrics, and gVCF creation: 14 hours & $35
1. 120 GB WGS BAM only: 11 hours
1. 4x40 GB WGS FASTQ files with AggMetrics, WgsMetrics, and gVCF creation: 23 hours & $72
1. 4x40 GB WGS FASTQ files only: 18 hours
1. 4x9 GB WXS FASTQ files with AggMetrics and gVCF creation: 4 hours & $9
1. 4x9 GB WXS FASTQ files only: 3 hours

#### Caveats:
1. Duplicates are flagged in a process that is connected to bwa mem. The implication of this design
   decision is that duplicates are flagged only on the inputs of that are scattered into bwa.
   Duplicates, therefore, are not being flagged at a library level and, for large BAM and FASTQ inputs,
   duplicates are only being detected within a portion of the read group.

#### Tips for running:
1. For the fastq input file lists (PE or SE), make sure the lists are properly ordered. The items in
   the arrays are processed based on their position. These lists are dotproduct scattered. This means
   that the first file in `input_pe_reads_list` is run with the first file in `input_pe_mates_list`
   and the first string in `input_pe_rgs_list`. This also means these arrays must be the same
   length or the workflow will fail.
1. The input for the reference_tar must be a tar file containing the reference fasta along with its indexes.
   The required indexes are `[.64.ann,.64.amb,.64.bwt,.64.pac,.64.sa,.dict,.fai]` and are generated by bwa, picard, and samtools.
   Additionally, an `.64.alt` index is recommended.
1. If you are making your own bwa indexes make sure to use the `-6` flag to obtain the `.64` version of the
   indexes. Indexes that do not match this naming schema will cause a failure in certain runner ecosystems.
1. Should you decide to create your own reference indexes and omit the ALT index file from the reference,
   or if its naming structure mismatches the other indexes, then your alignments will be equivalent to the results you would
   obtain if you run BWA-MEM with the -j option.
1. The following is an example of a complete reference tar input:
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
1. For advanced usage, you can skip the knownsite indexing by providing the knownsites_indexes input.
   This file list should contain the indexes for each of the files in your knownsites input. Please
   note this list must be ordered in such a way where the position of the index file in the
   knownsites_indexes list must correspond with the position of the VCF file in the knownsites list
   that it indexes. In the example input below you can see that the 1000G_omni2.5.hg38.vcf.gz.tbi
   file is the fourth item in the knownsites_indexes because the 1000G_omni2.5.hg38.vcf.gz file is the
   fourth item in the knownsites list. Failure to order in this way will result in the pipeline
   failing or generating erroneous files.
1. Turning off gVCF creation and metrics collection for a minimal successful run.
1. Suggested reference inputs (available from the [Broad Resource Bundle](https://console.cloud.google.com/storage/browser/genomics-public-data/resources/broad/hg38/v0)):
1. For large BAM inputs, users may encounter a scenario where jobs fail during
   the bamtofastq step. The given error will recommend that users try increasing
   disk space. Increasing the disk space will solve the error for all but the
   largest inputs. For those extremely large inputs with many read groups that
   continue to get this error, it is recommended that users increase the value for
   `bamtofastq_cpu`. Increasing this value will decrease the number of concurrent
   bamtofastq jobs that run on the same instance.
```yaml
contamination_sites_bed: Homo_sapiens_assembly38.contam.bed
contamination_sites_mu: Homo_sapiens_assembly38.contam.mu
contamination_sites_ud: Homo_sapiens_assembly38.contam.UD
dbsnp_vcf: Homo_sapiens_assembly38.dbsnp138.vcf
reference_tar: Homo_sapiens_assembly38.tgz
knownsites:
  - Homo_sapiens_assembly38.known_indels.vcf.gz
  - Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
  - 1000G_phase1.snps.high_confidence.hg38.vcf.gz
  - 1000G_omni2.5.hg38.vcf.gz
knownsites_indexes:
  - Homo_sapiens_assembly38.known_indels.vcf.gz.tbi
  - Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi
  - 1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi
  - 1000G_omni2.5.hg38.vcf.gz.tbi
```

![WF Visualized](https://github.com/kids-first/kf-alignment-workflow/blob/master/docs/kfdrc_alignment_gatk_hc_cyoa_wf.png?raw=true "BAM to CRAM to gVCF Workflow diagram")

## KFDRC GATK HaplotypeCaller CRAM to gVCF Workflow

This workflow taks a CRAM file, converts it to a BAM, determines a
contamination value, then runs GATK HaplotypeCaller to generate a gVCF, gVCF
calling metrics, and, if no contamination value is provided, the VerifyBAMID
output. Additionally, if the user sets the `run_sex_metrics` input to true, two
additional outputs from samtools idxstats will be provided.

This workflow is the current production workflow, equivalent to this [Cavatica public app](https://cavatica.sbgenomics.com/public/apps#cavatica/apps-publisher/kfdrc-gatk-haplotypecaller-workflow).

Read more [here](docs/KFDRC_GATK_HAPLOTYPECALLER_CRAM_TO_GVCF_WORKFLOW_README.md).

