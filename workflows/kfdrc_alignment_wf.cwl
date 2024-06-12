cwlVersion: v1.2
class: Workflow
id: kfdrc-alignment-workflow
label: Kids First DRC Alignment and GATK HaplotypeCaller Workflow
doc: |+
  # Kids First Data Resource Center Alignment and GATK HaplotypeCaller Workflows

  The Kids First Data Resource Center Alignment and Haplotype Calling Workflow (bam/fastq-to-cram, gVCF optional) follows
  Broad best practices outlined in [Data pre-processing for variant discovery.](https://gatk.broadinstitute.org/hc/en-us/articles/360035535912-Data-pre-processing-for-variant-discovery)
  It uses bam/fastq input and aligns/re-aligns to a bwa-indexed reference fasta, version hg38. Resultant bam is de-dupped and
  base score recalibrated. Contamination is calculated and a gVCF is created optionally using GATK4 vbeta.1-3.5 HaplotypeCaller. Inputs from
  this can be used later on for further analysis in joint trio genotyping and subsequent refinement and deNovo variant analysis. If you would like to run this workflow using the cavatica public app, a basic primer on running public apps can be found [here](https://www.notion.so/d3b/Starting-From-Scratch-Running-Cavatica-af5ebb78c38a4f3190e32e67b4ce12bb).
   Alternatively, if you'd like to run it locally using `cwltool`, a basic primer on that can be found [here](https://www.notion.so/d3b/Starting-From-Scratch-Running-CWLtool-b8dbbde2dc7742e4aff290b0a878344d) and combined with app-specific info from the readme below.
   This workflow is the current production workflow, equivalent to this [Cavatica public app](https://cavatica.sbgenomics.com/public/apps#cavatica/apps-publisher/kfdrc-alignment-workflow) and supersedes the [old workflow](https://github.com/kids-first/kf-alignment-workflow/tree/1.0.0) and [public app](https://cavatica.sbgenomics.com/public/apps#kids-first-drc/kids-first-drc-alignment-workflow/kfdrc-alignment-bam2cram2gvcf/); however outputs are considered equivalent.

  <p align="center">
    <img src="docs/kids_first_logo.svg" alt="Kids First repository logo" width="660px" />
  </p>
  <p align="center">
    <a href="https://github.com/kids-first/kf-alignment-workflow/blob/main/LICENSE"><img src="https://img.shields.io/github/license/kids-first/kf-alignment-workflow.svg?style=for-the-badge"></a>
  </p>

  ## Input Agnostic Alignment Workflow
  Workflow for the alignment or realignment of input SAMs/BAMs/CRAMs
  (Alignment/Map files, or AMs), PE reads, and/or SE reads; conditionally
  generate gVCF and metrics.

  This workflow is a all-in-one workflow for handling any kind of reads inputs:
  BAM inputs, PE reads and mates inputs, SE reads inputs,  or any combination of
  these. The workflow will naively attempt to process these depending on what you
  tell it you have provided. The user informs the workflow of which inputs to
  process using three boolean inputs: `run_bam_processing`,
  `run_pe_reads_processing`, and `run_se_reads_processing`. Providing `true`
  values for these as well their corresponding inputs will result in those inputs
  being processed.

  The second half of the workflow deals with optional gVCF creation and metrics
  collection.  This workflow is capable of collecting the metrics using the
  following boolean flags: `run_hs_metrics`, `run_wgs_metrics`, and
  `run_agg_metrics`. To run these metrics, additional optional inputs must also
  be provided: `wxs_bait_interval_list` and `wxs_target_interval_list` for
  HsMetrics, `wgs_coverage_interval_list` for WgsMetrics. To generate the gVCF,
  set `run_gvcf_processing` to `true` and provide the following optional files:
  `dbsnp_vcf`, `contamination_sites_bed`, `contamination_sites_mu`,
  `contamination_sites_ud`, `wgs_calling_interval_list`, and
  `wgs_evaluation_interval_list`. Additionally, the workflow is capable of
  performing a basic evaluation of the X and Y sex chromosomes using idxstats. To
  activate this feature, set `run_sex_metrics` to `true`; no additonal inputs are
  required. Finally, the workflow is capable of collecting HLA genotype data
  using [T1k](./docs/T1K_README.md). This feature is on by default but can be
  disabled by setting `run_t1k` to `false`. HLA genotyping also requires the
  `hla_dna_ref_seqs` and `hla_dna_gene_coords` inputs. The public app provides
  default files for these.

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
    cutadapt_r1_adapter: { type: 'string?', doc: "If read1 reads have an adapter, provide regular 3' adapter sequence here to remove it from read1" }
    cutadapt_r2_adapter: { type: 'string?', doc: "If read2 reads have an adapter, provide regular 3' adapter sequence here to remove it from read2" }
    cutadapt_min_len: { type: 'int?', doc: "If adapter trimming, discard reads/read-pairs where the read length is less than this value. Set to 0 to turn off" }
    cutadapt_quality_base: { type: 'int?', doc: "If adapter trimming, use this value as the base quality score. Defaults to 33 but very old reads might need this value set to 64" }
    cutadapt_quality_cutoff: { type: 'string?', doc: "If adapter trimming, remove bases from the 3'/5' that fail to meet this cutoff value. If you specify a single cutoff value, the 3' end of each read is trimmed. If you specify two cutoff values separated by a comma, the first value will be trimmed from the 5' and the second value will be trimmed from the 3'" }
    min_alignment_score: { type: 'int?', default: 30, doc: "For BWA MEM, Don't output alignment with score lower than INT. This option only affects output." }
    bamtofastq_cpu: { type: 'int?', doc: "CPUs to allocate to bamtofastq" }
    run_t1k: { type: 'boolean?', default: true, doc: "Set to false to disable T1k HLA typing" }
    hla_dna_ref_seqs: { type: 'File?', doc: "FASTA file containing the HLA allele reference sequences for DNA." }
    hla_dna_gene_coords: { type: 'File?', doc: "FASTA file containing the coordinates of the HLA genes for DNA." }
    t1k_abnormal_unmap_flag: { type: 'boolean?', doc: "Set if the flag in BAM for the unmapped read-pair is nonconcordant" }
  ```

  ### Outputs:
  ```yaml
    cram: {type: File, outputSource: samtools_bam_to_cram/output, doc: "(Re)Aligned Reads File"}
    gvcf: {type: 'File[]?', outputSource: generate_gvcf/gvcf, doc: "Genomic VCF generated from the realigned alignment file."}
    verifybamid_output: {type: 'File[]?', outputSource: generate_gvcf/verifybamid_output, doc: "Ouput from VerifyBamID that is used to calculate contamination."}
    cutadapt_stats: { type: 'File[]?', outputSource: collect_cutadapt_stats/out_filelist, doc: "Stats from Cutadapt runs, if run. One or more per read group." }
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
    t1k_genotype_tsv: {type: 'File?', outputSource: t1k/genotype_tsv, doc: "HLA genotype results from T1k" }
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

requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement
- class: InlineJavascriptRequirement
  expressionLib:
  - |-
    //https://stackoverflow.com/a/27267762
    var flatten = function flatten(ary) {
        var ret = [];
        for(var i = 0; i < ary.length; i++) {
            if(Array.isArray(ary[i])) {
                ret = ret.concat(flatten(ary[i]));
            } else {
                ret.push(ary[i]);
            }
        }
        return ret;
    }

inputs:
  input_bam_list: {type: 'File[]?', doc: "List of input BAM files"}
  input_pe_reads_list: {type: 'File[]?', doc: "List of input R1 paired end fastq reads"}
  input_pe_mates_list: {type: 'File[]?', doc: "List of input R2 paired end fastq reads"}
  input_pe_rgs_list: {type: 'string[]?', doc: "List of RG strings to use in PE processing"}
  input_se_reads_list: {type: 'File[]?', doc: "List of input singlie end fastq reads"}
  input_se_rgs_list: {type: 'string[]?', doc: "List of RG strings to use in SE processing"}
  reference_tar: {type: File, doc: "Tar file containing a reference fasta and, optionally, its complete set of associated indexes
      (samtools, bwa, and picard)", "sbg:suggestedValue": {class: File, path: 5f4ffff4e4b0370371c05153, name: Homo_sapiens_assembly38.tgz}}
  cram_reference: {type: 'File?', doc: "If aligning from cram, need to provided reference used to generate that cram"}
  biospecimen_name: {type: string, doc: "String name of biospcimen"}
  output_basename: {type: string, doc: "String to use as the base for output filenames"}
  dbsnp_vcf: {type: 'File?', doc: "dbSNP vcf file", "sbg:suggestedValue": {class: File, path: 6063901f357c3a53540ca84b, name: Homo_sapiens_assembly38.dbsnp138.vcf}}
  dbsnp_idx: {type: 'File?', doc: "dbSNP vcf index file", "sbg:suggestedValue": {class: File, path: 6063901e357c3a53540ca834, name: Homo_sapiens_assembly38.dbsnp138.vcf.idx}}
  knownsites: {type: 'File[]', doc: "List of files containing known polymorphic sites used to exclude regions around known polymorphisms
      from analysis", "sbg:suggestedValue": [{class: File, path: 6063901e357c3a53540ca835, name: 1000G_omni2.5.hg38.vcf.gz}, {class: File,
        path: 6063901c357c3a53540ca80f, name: 1000G_phase1.snps.high_confidence.hg38.vcf.gz}, {class: File, path: 60639017357c3a53540ca7d0,
        name: Homo_sapiens_assembly38.known_indels.vcf.gz}, {class: File, path: 6063901a357c3a53540ca7f3, name: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz}]}
  knownsites_indexes: {type: 'File[]?', doc: "Corresponding indexes for the knownsites. File position in list must match with its
      corresponding VCF's position in the knownsites file list. For example, if the first file in the knownsites list is 1000G_omni2.5.hg38.vcf.gz
      then the first item in this list must be 1000G_omni2.5.hg38.vcf.gz.tbi. Optional, but will save time/cost on indexing.", "sbg:suggestedValue": [
      {class: File, path: 60639016357c3a53540ca7b1, name: 1000G_omni2.5.hg38.vcf.gz.tbi}, {class: File, path: 6063901e357c3a53540ca845,
        name: 1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi}, {class: File, path: 6063901c357c3a53540ca80d, name: Homo_sapiens_assembly38.known_indels.vcf.gz.tbi},
      {class: File, path: 6063901c357c3a53540ca806, name: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi}]}
  contamination_sites_bed: {type: 'File?', doc: ".bed file for markers used in this analysis,format(chr\tpos-1\tpos\trefAllele\taltAllele)",
    "sbg:suggestedValue": {class: File, path: 6063901e357c3a53540ca833, name: Homo_sapiens_assembly38.contam.bed}}
  contamination_sites_mu: {type: 'File?', doc: ".mu matrix file of genotype matrix", "sbg:suggestedValue": {class: File, path: 60639017357c3a53540ca7cd,
      name: Homo_sapiens_assembly38.contam.mu}}
  contamination_sites_ud: {type: 'File?', doc: ".UD matrix file from SVD result of genotype matrix", "sbg:suggestedValue": {class: File,
      path: 6063901f357c3a53540ca84f, name: Homo_sapiens_assembly38.contam.UD}}
  wgs_calling_interval_list: {type: 'File?', doc: "WGS interval list used to aid scattering Haplotype caller", "sbg:suggestedValue": {
      class: File, path: 60639018357c3a53540ca7df, name: wgs_calling_regions.hg38.interval_list}}
  wgs_coverage_interval_list: {type: 'File?', doc: "An interval list file that contains the positions to restrict the wgs metrics
      assessment", "sbg:suggestedValue": {class: File, path: 6063901c357c3a53540ca813, name: wgs_coverage_regions.hg38.interval_list}}
  wgs_evaluation_interval_list: {type: 'File?', doc: "Target intervals to restrict gvcf metric analysis (for VariantCallingMetrics)",
    "sbg:suggestedValue": {class: File, path: 60639017357c3a53540ca7d3, name: wgs_evaluation_regions.hg38.interval_list}}
  wxs_bait_interval_list: {type: 'File?', doc: "An interval list file that contains the locations of the WXS baits used (for HsMetrics)"}
  wxs_target_interval_list: {type: 'File?', doc: "An interval list file that contains the locations of the WXS targets (for HsMetrics)"}
  run_bam_processing: {type: boolean, doc: "BAM processing will be run. Requires: input_bam_list"}
  run_pe_reads_processing: {type: boolean, doc: "PE reads processing will be run. Requires: input_pe_reads_list, input_pe_mates_list,
      input_pe_rgs_list"}
  run_se_reads_processing: {type: boolean, doc: "SE reads processing will be run. Requires: input_se_reads_list, input_se_rgs_list"}
  run_hs_metrics: {type: boolean, doc: "HsMetrics will be collected. Only recommended for WXS inputs. Requires: wxs_bait_interval_list,
      wxs_target_interval_list"}
  run_wgs_metrics: {type: boolean, doc: "WgsMetrics will be collected. Only recommended for WGS inputs. Requires: wgs_coverage_interval_list"}
  run_agg_metrics: {type: boolean, doc: "AlignmentSummaryMetrics, GcBiasMetrics, InsertSizeMetrics, QualityScoreDistribution, and
      SequencingArtifactMetrics will be collected. Recommended for both WXS and WGS inputs."}
  run_sex_metrics: {type: boolean, doc: "idxstats will be collected and X/Y ratios calculated"}
  run_gvcf_processing: {type: boolean, doc: "gVCF will be generated. Requires: dbsnp_vcf, contamination_sites_bed, contamination_sites_mu,
      contamination_sites_ud, wgs_calling_interval_list, wgs_evaluation_interval_list"}
  cutadapt_r1_adapter: {type: 'string?', doc: "If read1 reads have an adapter, provide regular 3' adapter sequence here to remove
      it from read1"}
  cutadapt_r2_adapter: {type: 'string?', doc: "If read2 reads have an adapter, provide regular 3' adapter sequence here to remove
      it from read2"}
  cutadapt_min_len: {type: 'int?', doc: "If adapter trimming, discard reads/read-pairs where the read length is less than this value.
      Set to 0 to turn off"}
  cutadapt_quality_base: {type: 'int?', doc: "If adapter trimming, use this value as the base quality score. Defaults to 33 but very
      old reads might need this value set to 64"}
  cutadapt_quality_cutoff: {type: 'string?', doc: "If adapter trimming, remove bases from the 3'/5' that fail to meet this cutoff
      value. If you specify a single cutoff value, the 3' end of each read is trimmed. If you specify two cutoff values separated
      by a comma, the first value will be trimmed from the 5' and the second value will be trimmed from the 3'"}
  min_alignment_score: {type: 'int?', default: 30, doc: "For BWA MEM, Don't output alignment with score lower than INT. This option
      only affects output."}
  bamtofastq_cpu: {type: 'int?', doc: "CPUs to allocate to bamtofastq"}
  run_t1k: {type: 'boolean?', default: true, doc: "Set to false to disable T1k HLA typing"}
  hla_dna_ref_seqs: {type: 'File?', doc: "FASTA file containing the HLA allele reference sequences for DNA.", "sbg:suggestedValue": {
      class: File, path: 6669ac8127374715fc3ba3c4, name: hla_v3.43.0_gencode_v39_dna_seq.fa}}
  hla_dna_gene_coords: {type: 'File?', doc: "FASTA file containing the coordinates of the HLA genes for DNA.", "sbg:suggestedValue": {
      class: File, path: 6669ac8127374715fc3ba3c2, name: hla_v3.43.0_gencode_v39_dna_coord.fa}}
  t1k_abnormal_unmap_flag: {type: 'boolean?', doc: "Set if the flag in BAM for the unmapped read-pair is nonconcordant"}
outputs:
  cram: {type: File, outputSource: samtools_bam_to_cram/output, doc: "(Re)Aligned Reads File"}
  gvcf: {type: 'File[]?', outputSource: generate_gvcf/gvcf, doc: "Genomic VCF generated from the realigned alignment file."}
  cutadapt_stats: {type: 'File[]?', outputSource: collect_cutadapt_stats/out_filelist, doc: "Stats from Cutadapt runs, if run. One
      or more per read group."}
  verifybamid_output: {type: 'File[]?', outputSource: generate_gvcf/verifybamid_output, doc: "Ouput from VerifyBamID that is used
      to calculate contamination."}
  bqsr_report: {type: File, outputSource: gatk_gatherbqsrreports/output, doc: "Recalibration report from BQSR."}
  gvcf_calling_metrics: {type: ['null', {type: array, items: {type: array, items: File}}], outputSource: generate_gvcf/gvcf_calling_metrics,
    doc: "General metrics for gVCF calling quality."}
  hs_metrics: {type: 'File[]?', outputSource: picard_collecthsmetrics/output, doc: "Picard CollectHsMetrics metrics for the analysis
      of target-capture sequencing experiments."}
  wgs_metrics: {type: 'File[]?', outputSource: picard_collectwgsmetrics/output, doc: "Picard CollectWgsMetrics metrics for evaluating
      the performance of whole genome sequencing experiments."}
  alignment_metrics: {type: 'File[]?', outputSource: picard_collectalignmentsummarymetrics/output, doc: "Picard CollectAlignmentSummaryMetrics
      high level metrics about the alignment of reads within a SAM file."}
  gc_bias_detail: {type: 'File[]?', outputSource: picard_collectgcbiasmetrics/detail, doc: "Picard CollectGcBiasMetrics detailed metrics
      about reads that fall within windows of a certain GC bin on the reference genome."}
  gc_bias_summary: {type: 'File[]?', outputSource: picard_collectgcbiasmetrics/summary, doc: "Picard CollectGcBiasMetrics high level
      metrics that capture how biased the coverage in a certain lane is."}
  gc_bias_chart: {type: 'File[]?', outputSource: picard_collectgcbiasmetrics/chart, doc: "Picard CollectGcBiasMetrics plot of GC bias."}
  insert_metrics: {type: 'File[]?', outputSource: picard_collectinsertsizemetrics/metrics, doc: "Picard CollectInsertSizeMetrics metrics
      about the insert size distribution of a paired-end library."}
  insert_plot: {type: 'File[]?', outputSource: picard_collectinsertsizemetrics/plot, doc: "Picard CollectInsertSizeMetrics insert
      size distribution plotted."}
  artifact_bait_bias_detail_metrics: {type: 'File[]?', outputSource: picard_collectsequencingartifactmetrics/bait_bias_detail_metrics,
    doc: "Picard CollectSequencingArtifactMetrics bait bias artifacts broken down by context."}
  artifact_bait_bias_summary_metrics: {type: 'File[]?', outputSource: picard_collectsequencingartifactmetrics/bait_bias_summary_metrics,
    doc: "Picard CollectSequencingArtifactMetrics summary analysis of a single bait bias artifact."}
  artifact_error_summary_metrics: {type: 'File[]?', outputSource: picard_collectsequencingartifactmetrics/error_summary_metrics, doc: "Picard
      CollectSequencingArtifactMetrics summary metrics as a roll up of the context-specific error rates, to provide global error rates
      per type of base substitution."}
  artifact_pre_adapter_detail_metrics: {type: 'File[]?', outputSource: picard_collectsequencingartifactmetrics/pre_adapter_detail_metrics,
    doc: "Picard CollectSequencingArtifactMetrics pre-adapter artifacts broken down by context."}
  artifact_pre_adapter_summary_metrics: {type: 'File[]?', outputSource: picard_collectsequencingartifactmetrics/pre_adapter_summary_metrics,
    doc: "Picard CollectSequencingArtifactMetrics summary analysis of a single pre-adapter artifact."}
  qual_metrics: {type: 'File[]?', outputSource: picard_qualityscoredistribution/metrics, doc: "Quality metrics for the realigned CRAM."}
  qual_chart: {type: 'File[]?', outputSource: picard_qualityscoredistribution/chart, doc: "Visualization of quality metrics."}
  idxstats: {type: 'File?', outputSource: samtools_idxstats_xy_ratio/output, doc: "samtools idxstats of the realigned BAM file."}
  xy_ratio: {type: 'File?', outputSource: samtools_idxstats_xy_ratio/ratio, doc: "Text file containing X and Y reads statistics generated
      from idxstats."}
  t1k_genotype_tsv: {type: 'File?', outputSource: t1k/genotype_tsv, doc: "HLA genotype results from T1k"}
steps:
  untar_reference:
    run: ../tools/untar_indexed_reference.cwl
    in:
      reference_tar: reference_tar
    out: [fasta, fai, dict, alt, amb, ann, bwt, pac, sa]
  bundle_secondaries:
    run: ../tools/bundle_secondaryfiles.cwl
    in:
      primary_file: untar_reference/fasta
      secondary_files:
        source: [untar_reference/fai, untar_reference/dict, untar_reference/alt, untar_reference/amb, untar_reference/ann, untar_reference/bwt,
          untar_reference/pac, untar_reference/sa]
        linkMerge: merge_flattened
    out: [output]
  pad_knownsites_indexes:
    run:
      class: CommandLineTool
      cwlVersion: v1.2
      baseCommand: [echo, done]
      inputs:
        in_filelist:
          type:
            type: array
            items: ['null', File]
      outputs:
        out_filelist:
          type:
            type: array
            items: ['null', File]
          outputBinding:
            outputEval: $(inputs.in_filelist)
    in:
      in_filelist:
        source: [knownsites, knownsites_indexes]
        valueFrom: |
          $(self[0].map(function(v,i) { return (self[1] != null ? self[1][i] : self[1]) }))
    out: [out_filelist]
  index_knownsites:
    run: ../tools/tabix_index.cwl
    in:
      input_file: knownsites
      input_index: pad_knownsites_indexes/out_filelist
    scatter: [input_file, input_index]
    scatterMethod: dotproduct
    out: [output]
  gatekeeper:
    run: ../tools/gatekeeper.cwl
    in:
      run_bam_processing: run_bam_processing
      run_pe_reads_processing: run_pe_reads_processing
      run_se_reads_processing: run_se_reads_processing
      run_hs_metrics: run_hs_metrics
      run_wgs_metrics: run_wgs_metrics
      run_agg_metrics: run_agg_metrics
      run_gvcf_processing: run_gvcf_processing
    out: [scatter_bams, scatter_pe_reads, scatter_se_reads, scatter_gvcf, scatter_hs_metrics, scatter_wgs_metrics, scatter_agg_metrics]
  process_bams:
    run: ../subworkflows/kfdrc_process_bamlist.cwl
    in:
      input_bam_list: input_bam_list
      indexed_reference_fasta: bundle_secondaries/output
      sample_name: biospecimen_name
      conditional_run: gatekeeper/scatter_bams
      output_basename: output_basename
      cutadapt_r1_adapter: cutadapt_r1_adapter
      cutadapt_r2_adapter: cutadapt_r2_adapter
      cutadapt_min_len: cutadapt_min_len
      cutadapt_quality_base: cutadapt_quality_base
      cutadapt_quality_cutoff: cutadapt_quality_cutoff
      min_alignment_score: min_alignment_score
      cram_reference: cram_reference
      bamtofastq_cpu: bamtofastq_cpu
    scatter: conditional_run
    out: [unsorted_bams, cutadapt_stats] #+2 Nesting File[][][]

  process_pe_reads:
    run: ../subworkflows/kfdrc_process_pe_readslist2.cwl
    in:
      indexed_reference_fasta: bundle_secondaries/output
      input_pe_reads_list: input_pe_reads_list
      input_pe_mates_list: input_pe_mates_list
      input_pe_rgs_list: input_pe_rgs_list
      conditional_run: gatekeeper/scatter_pe_reads
      output_basename: output_basename
      cutadapt_r1_adapter: cutadapt_r1_adapter
      cutadapt_r2_adapter: cutadapt_r2_adapter
      cutadapt_min_len: cutadapt_min_len
      cutadapt_quality_base: cutadapt_quality_base
      cutadapt_quality_cutoff: cutadapt_quality_cutoff
      min_alignment_score: min_alignment_score
    scatter: conditional_run
    out: [unsorted_bams, cutadapt_stats] #+0 Nesting File[]

  process_se_reads:
    run: ../subworkflows/kfdrc_process_se_readslist2.cwl
    in:
      indexed_reference_fasta: bundle_secondaries/output
      input_se_reads_list: input_se_reads_list
      input_se_rgs_list: input_se_rgs_list
      conditional_run: gatekeeper/scatter_se_reads
      output_basename: output_basename
      cutadapt_r1_adapter: cutadapt_r1_adapter
      cutadapt_min_len: cutadapt_min_len
      cutadapt_quality_base: cutadapt_quality_base
      cutadapt_quality_cutoff: cutadapt_quality_cutoff
      min_alignment_score: min_alignment_score
    scatter: conditional_run
    out: [unsorted_bams, cutadapt_stats] #+0 Nesting File[]

  collect_cutadapt_stats:
    run:
      class: CommandLineTool
      cwlVersion: v1.2
      baseCommand: [echo, done]
      requirements:
      - class: InlineJavascriptRequirement
        expressionLib:
        - |-
          //https://stackoverflow.com/a/27267762
          var flatten = function flatten(ary) {
              var ret = [];
              for(var i = 0; i < ary.length; i++) {
                  if(Array.isArray(ary[i])) {
                      ret = ret.concat(flatten(ary[i]));
                  } else {
                      ret.push(ary[i]);
                  }
              }
              return ret;
          }
      inputs:
        in_filelist: {type: 'Any?'}
      outputs:
        out_filelist:
          type: File[]?
          outputBinding:
            outputEval: |
              ${
                var flatarray = flatten(inputs.in_filelist);
                var filearray = flatarray.filter(function(e) { return e != null });
                var outarr = filearray.length > 0 ? filearray : null;
                return outarr;
              }
    when: $(inputs.in_filelist.some(function(e) { return e != null }))
    in:
      in_filelist:
        source: [process_bams/cutadapt_stats, process_pe_reads/cutadapt_stats, process_se_reads/cutadapt_stats]
    out: [out_filelist]
  sambamba_merge:
    hints:
    - class: "sbg:AWSInstanceType"
      value: c5.9xlarge;ebs-gp2;2048
    run: ../tools/sambamba_merge_anylist.cwl
    in:
      bams:
        source: [process_bams/unsorted_bams, process_pe_reads/unsorted_bams, process_se_reads/unsorted_bams]
        valueFrom: |
          $(flatten(self))
      base_file_name: output_basename
    out: [merged_bam]
  sambamba_sort:
    hints:
    - class: "sbg:AWSInstanceType"
      value: c5.9xlarge;ebs-gp2;2048
    run: ../tools/sambamba_sort.cwl
    in:
      bam: sambamba_merge/merged_bam
      base_file_name: output_basename
    out: [sorted_bam]
  python_createsequencegroups:
    run: ../tools/python_createsequencegroups.cwl
    in:
      ref_dict: untar_reference/dict
    out: [sequence_intervals, sequence_intervals_with_unmapped]
  gatk_baserecalibrator:
    run: ../tools/gatk_baserecalibrator.cwl
    in:
      input_bam: sambamba_sort/sorted_bam
      knownsites: index_knownsites/output
      reference: bundle_secondaries/output
      sequence_interval: python_createsequencegroups/sequence_intervals
    scatter: [sequence_interval]
    out: [output]
  gatk_gatherbqsrreports:
    run: ../tools/gatk_gatherbqsrreports.cwl
    in:
      input_brsq_reports: gatk_baserecalibrator/output
      output_basename: output_basename
    out: [output]
  gatk_applybqsr:
    run: ../tools/gatk_applybqsr.cwl
    in:
      bqsr_report: gatk_gatherbqsrreports/output
      input_bam: sambamba_sort/sorted_bam
      reference: bundle_secondaries/output
      sequence_interval: python_createsequencegroups/sequence_intervals_with_unmapped
    scatter: [sequence_interval]
    out: [recalibrated_bam]
  picard_gatherbamfiles:
    run: ../tools/picard_gatherbamfiles.cwl
    in:
      input_bam: gatk_applybqsr/recalibrated_bam
      output_bam_basename: output_basename
    out: [output]
  t1k:
    run: ../tools/t1k.cwl
    when: $(inputs.run_t1k)
    in:
      run_t1k: run_t1k
      bam: picard_gatherbamfiles/output
      reference: hla_dna_ref_seqs
      gene_coordinates: hla_dna_gene_coords
      abnormal_unmap_flag: t1k_abnormal_unmap_flag
      preset:
        valueFrom: "hla"
      output_basename:
        source: output_basename
        valueFrom: $(self).t1k_hla
      skip_post_analysis:
        valueFrom: $(1 == 1)
    out: [genotype_tsv]
  samtools_bam_to_cram:
    run: ../tools/samtools_bam_to_cram.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: bundle_secondaries/output
    out: [output]
  picard_collecthsmetrics:
    run: ../tools/picard_collecthsmetrics_conditional.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      bait_intervals: wxs_bait_interval_list
      target_intervals: wxs_target_interval_list
      reference: bundle_secondaries/output
      conditional_run: gatekeeper/scatter_hs_metrics
    scatter: conditional_run
    out: [output]
  picard_collectwgsmetrics:
    run: ../tools/picard_collectwgsmetrics_conditional.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      intervals: wgs_coverage_interval_list
      reference: bundle_secondaries/output
      conditional_run: gatekeeper/scatter_wgs_metrics
    scatter: conditional_run
    out: [output]
  picard_collectalignmentsummarymetrics:
    run: ../tools/picard_collectalignmentsummarymetrics_conditional.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: bundle_secondaries/output
      conditional_run: gatekeeper/scatter_agg_metrics
    scatter: conditional_run
    out: [output]
  picard_collectgcbiasmetrics:
    run: ../tools/picard_collectgcbiasmetrics_conditional.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: bundle_secondaries/output
      conditional_run: gatekeeper/scatter_agg_metrics
    scatter: conditional_run
    out: [detail, summary, chart]
  picard_collectinsertsizemetrics:
    run: ../tools/picard_collectinsertsizemetrics_conditional.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: bundle_secondaries/output
      conditional_run: gatekeeper/scatter_agg_metrics
    scatter: conditional_run
    out: [metrics, plot]
  picard_collectsequencingartifactmetrics:
    run: ../tools/picard_collectsequencingartifactmetrics_conditional.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: bundle_secondaries/output
      conditional_run: gatekeeper/scatter_agg_metrics
    scatter: conditional_run
    out: [bait_bias_detail_metrics, bait_bias_summary_metrics, error_summary_metrics, pre_adapter_detail_metrics, pre_adapter_summary_metrics]
  picard_qualityscoredistribution:
    run: ../tools/picard_qualityscoredistribution_conditional.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: bundle_secondaries/output
      conditional_run: gatekeeper/scatter_agg_metrics
    scatter: conditional_run
    out: [metrics, chart]
  samtools_idxstats_xy_ratio:
    run: ../tools/samtools_idxstats_xy_ratio.cwl
    in:
      run_idxstats: run_sex_metrics
      input_bam: picard_gatherbamfiles/output
    out: [output, ratio]
  generate_gvcf:
    run: ../subworkflows/kfdrc_bam_to_gvcf.cwl
    in:
      biospecimen_name: biospecimen_name
      contamination_sites_bed: contamination_sites_bed
      contamination_sites_mu: contamination_sites_mu
      contamination_sites_ud: contamination_sites_ud
      input_bam: picard_gatherbamfiles/output
      indexed_reference_fasta: bundle_secondaries/output
      output_basename: output_basename
      dbsnp_vcf: dbsnp_vcf
      dbsnp_idx: dbsnp_idx
      reference_dict: untar_reference/dict
      wgs_calling_interval_list: wgs_calling_interval_list
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
      conditional_run: gatekeeper/scatter_gvcf
    scatter: conditional_run
    out: [verifybamid_output, gvcf, gvcf_calling_metrics]
$namespaces:
  sbg: https://sevenbridges.com
hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 4
"sbg:license": Apache License 2.0
"sbg:publisher": KFDRC
"sbg:categories":
- ALIGNMENT
- DNA
- WGS
- WXS
- GVCF
"sbg:links":
- id: 'https://github.com/kids-first/kf-alignment-workflow/releases/tag/v2.10.0'
  label: github-release
