cwlVersion: v1.2
class: Workflow
id: kfdrc-sentieon-alignment-workflow
label: Kids First DRC Sentieon Alignment and gVCF Workflow
doc: |
  # Kids First Data Resource Center Sentieon Short Reads Alignment and gVCF Workflow

  <p align="center">
    <img src="https://github.com/d3b-center/d3b-research-workflows/raw/master/doc/kfdrc-logo-sm.png">
  </p>

  The Kids First Data Resource Center (KFDRC) Short Reads Alignment and GATK
  Haplotyper Workflow is a Common Workflow Language (CWL) implementation of
  various software used to take reads generated by next generation sequencing
  (NGS) technologies and use those reads to generate alignment and, optionally,
  variant information. This workflow mirrors the approach of our existing [Input Agnostic Alignment Workflow](https://github.com/kids-first/kf-alignment-workflow#input-agnostic-alignment-workflow),
  and the two have been internally benchmarked as functionally equivalent. The key
  difference between the two workflows is found in the tools used during the
  alignment process.

  This pipeline was made possible thanks to significant software and support
  contributions from Sentieon. For more information on our collaborators, check
  out their website:
  - Sentieon: https://www.sentieon.com/

  ## Relevant Softwares and Versions

  - [Sentieon](https://support.sentieon.com/manual/DNAseq_usage/dnaseq/): `202112.01`

  ## Input Files

  This workflow has a unique input `sentieon_license` that is not present in our
  main alignment workflow. To run the Sentieon tool, users must provide the license
  value to run any of the Sentieon tools. We have provided a default value that
  works exclusively on Cavatica. Alternatively, if you wish to use this outside
  of Cavatica, you will need to provide your own server license.

  Otherwise, this workflow uses identical inputs as our existing alignment workflow.
  For more information see: https://github.com/kids-first/kf-alignment-workflow#inputs

  ## Output Files

  This workflow generates outputs identical to our existing alignment workflow.
  For more information see: https://github.com/kids-first/kf-alignment-workflow#outputs

  ## Sentieon Alignment: Similarities and Differences

  The two workflows start identically; both workflows start by splitting the
  input SAMs/BAMs/CRAMs (Alignment/Map files, or AMs) into read group (RG) AMs using samtools split then convert those RG
  AMs into FASTQ files using biobambam2 bamtofastq. After FASTQ creation, the
  two workflows diverge in software usage. Whereas the KFDRC GATK pipeline uses a
  wide variety of tools (bwa, sambamba, samblaster, GATK, Picard, and samtools)
  to generate the realigned CRAMs, the KFDRC Sentieon pipeline uses exclusively
  software implementations from Sentieon, such as their modified version of
  bwa. One notable difference in the flow of the pipeline is where MarkDuplicates
  is run. In the original workflow, RG BAMs are split if they are too large.
  Duplicate Marking is then run on those individual shards rather than the
  complete RG BAMs. In this workflow, however, duplicates are marked over the
  whole RG BAM file. Overall this results in a slightly higher rate of marked
  duplicates and slightly lower mean coverage. For more information about the
  process in the main workflow see https://github.com/kids-first/kf-alignment-workflow#caveats.

  Finally, the metrics collection is done with a series of Sentieon algorithms
  that match our existing Picard metrics suite.

  | Step                       | KFDRC GATK            | KFDRC Sentieon                    |
  |----------------------------|-----------------------|-----------------------------------|
  | Bam to Read Group (RG) BAM | samtools split        | samtools split                    |
  | RG Bam to Fastq            | biobambam2 bamtofastq | biobambam2 bamtofastq             |
  | Fastq to RG Bam            | bwa mem               | Sentieon bwa mem                  |
  | Merge RG Bams              | sambamba merge        | Sentieon ReadWriter               |
  | Sort Bam                   | sambamba sort         | Sentieon ReadWriter               |
  | Mark Duplicates            | samblaster            | Sentieon LocusCollector + Dedup   |
  | BaseRecalibration          | GATK BaseRecalibrator | Sentieon QualCal                  |
  | ApplyRecalibration         | GATK ApplyBQSR        | Sentieon ReadWriter QualCalFilter |
  | Gather Recalibrated BAMs   | Picard GatherBamFiles | No splitting occurs in Sentieon   |
  | Bam to Cram                | samtools view         | Sentieon ReadWriter               |
  | Metrics                    | Picard                | Sentieon                          |

  ## Sentieon gVCF Creation: Similarities and Differences

  After the creation of a recalibrated BAM, if the user wishes, a gVCF file and
  associated metrics are generated. The Sentieon approach is to run Haplotyper on
  the recalibrated reads. Like base recalibration, these steps are accomplished
  without scattering and therefore no additional merging steps are required.
  Metrics collection and contamination estimation are unchanged.

  | Step                       | KFDRC GATK                          | KFDRC Sentieon                      |
  |----------------------------|-------------------------------------|-------------------------------------|
  | Contamination Calculation  | VerifyBamID                         | VerifyBamID                         |
  | gVCF Calling               | GATK HaplotypeCaller                | Senteion Haplotyper                 |
  | Gather VCFs                | Picard MergeVcfs                    | No splitting occurs in Sentieon     |
  | Metrics                    | Picard CollectVariantCallingMetrics | Picard CollectVariantCallingMetrics |

  ## Basic Info
  - [D3b dockerfiles](https://github.com/d3b-center/bixtools)
  - Testing Tools:
      - [Seven Bridges Cavatica Platform](https://cavatica.sbgenomics.com/)
      - [Common Workflow Language reference implementation (cwltool)](https://github.com/common-workflow-language/cwltool/)

  ## References
  - KFDRC AWS s3 bucket: s3://kids-first-seq-data/broad-references/
  - Cavatica: https://cavatica.sbgenomics.com/u/kfdrc-harmonization/kf-references/
  - Sentieon: https://support.sentieon.com/manual/DNAseq_usage/dnaseq/
  - Broad Institute Goolge Cloud: https://console.cloud.google.com/storage/browser/genomics-public-data/resources/broad/hg38/v0/
requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement
- class: InlineJavascriptRequirement
inputs:
  sentieon_license: {type: 'string?', default: "10.5.64.221:8990", doc: "License server
      host and port"}
  input_bam_list: {type: 'File[]?', doc: "List of input BAM files"}
  input_pe_reads_list: {type: 'File[]?', doc: "List of input R1 paired end fastq reads"}
  input_pe_mates_list: {type: 'File[]?', doc: "List of input R2 paired end fastq reads"}
  input_pe_rgs_list: {type: 'string[]?', doc: "List of RG strings to use in PE processing"}
  input_se_reads_list: {type: 'File[]?', doc: "List of input single end fastq reads"}
  input_se_rgs_list: {type: 'string[]?', doc: "List of RG strings to use in SE processing"}
  reference_tar: {type: File, doc: "Tar file containing a reference fasta and, optionally,
      its complete set of associated indexes (samtools, bwa, and picard)", "sbg:suggestedValue": {
      class: File, path: 5f4ffff4e4b0370371c05153, name: Homo_sapiens_assembly38.tgz}}
  cram_reference: {type: 'File?', doc: "If aligning from cram, need to provided reference
      used to generate that cram"}
  biospecimen_name: {type: string, doc: "String name of biospcimen"}
  output_basename: {type: string, doc: "String to use as the base for output filenames"}
  dbsnp_vcf: {type: 'File?', doc: "dbSNP vcf file", "sbg:suggestedValue": {class: File,
      path: 6063901f357c3a53540ca84b, name: Homo_sapiens_assembly38.dbsnp138.vcf}}
  dbsnp_idx: {type: 'File?', doc: "dbSNP vcf index file", "sbg:suggestedValue": {
      class: File, path: 6063901e357c3a53540ca834, name: Homo_sapiens_assembly38.dbsnp138.vcf.idx}}
  knownsites: {type: 'File[]', doc: "List of files containing known polymorphic sites
      used to exclude regions around known polymorphisms from analysis", "sbg:suggestedValue": [
      {class: File, path: 6063901e357c3a53540ca835, name: 1000G_omni2.5.hg38.vcf.gz},
      {class: File, path: 6063901c357c3a53540ca80f, name: 1000G_phase1.snps.high_confidence.hg38.vcf.gz},
      {class: File, path: 60639017357c3a53540ca7d0, name: Homo_sapiens_assembly38.known_indels.vcf.gz},
      {class: File, path: 6063901a357c3a53540ca7f3, name: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz}]}
  knownsites_indexes: {type: 'File[]?', doc: "Corresponding indexes for the knownsites.
      File position in list must match with its corresponding VCF's position in the
      knownsites file list. For example, if the first file in the knownsites list
      is 1000G_omni2.5.hg38.vcf.gz then the first item in this list must be 1000G_omni2.5.hg38.vcf.gz.tbi.
      Optional, but will save time/cost on indexing.", "sbg:suggestedValue": [{class: File,
        path: 60639016357c3a53540ca7b1, name: 1000G_omni2.5.hg38.vcf.gz.tbi}, {class: File,
        path: 6063901e357c3a53540ca845, name: 1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi},
      {class: File, path: 6063901c357c3a53540ca80d, name: Homo_sapiens_assembly38.known_indels.vcf.gz.tbi},
      {class: File, path: 6063901c357c3a53540ca806, name: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi}]}
  contamination_sites_bed: {type: 'File?', doc: ".bed file for markers used in this
      analysis,format(chr\tpos-1\tpos\trefAllele\taltAllele)", "sbg:suggestedValue": {
      class: File, path: 6063901e357c3a53540ca833, name: Homo_sapiens_assembly38.contam.bed}}
  contamination_sites_mu: {type: 'File?', doc: ".mu matrix file of genotype matrix",
    "sbg:suggestedValue": {class: File, path: 60639017357c3a53540ca7cd, name: Homo_sapiens_assembly38.contam.mu}}
  contamination_sites_ud: {type: 'File?', doc: ".UD matrix file from SVD result of
      genotype matrix", "sbg:suggestedValue": {class: File, path: 6063901f357c3a53540ca84f,
      name: Homo_sapiens_assembly38.contam.UD}}
  wgs_coverage_interval_list: {type: 'File?', doc: "An interval list file that contains
      the positions to restrict the wgs metrics assessment", "sbg:suggestedValue": {
      class: File, path: 6063901c357c3a53540ca813, name: wgs_coverage_regions.hg38.interval_list}}
  wgs_evaluation_interval_list: {type: 'File?', doc: "Target intervals to restrict
      gvcf metric analysis (for VariantCallingMetrics)", "sbg:suggestedValue": {class: File,
      path: 60639017357c3a53540ca7d3, name: wgs_evaluation_regions.hg38.interval_list}}
  wxs_bait_interval_list: {type: 'File?', doc: "An interval list file that contains
      the locations of the WXS baits used (for HsMetrics)"}
  wxs_target_interval_list: {type: 'File?', doc: "An interval list file that contains
      the locations of the WXS targets (for HsMetrics)"}
  run_hs_metrics: {type: boolean, doc: "HsMetrics will be collected. Only recommended
      for WXS inputs. Requires: wxs_bait_interval_list, wxs_target_interval_list"}
  run_wgs_metrics: {type: boolean, doc: "WgsMetrics will be collected. Only recommended
      for WGS inputs. Requires: wgs_coverage_interval_list"}
  run_agg_metrics: {type: boolean, doc: "AlignmentSummaryMetrics, GcBiasMetrics, InsertSizeMetrics,
      QualityScoreDistribution, and SequencingArtifactMetrics will be collected. Recommended
      for both WXS and WGS inputs."}
  run_sex_metrics: {type: boolean, doc: "idxstats will be collected and X/Y ratios
      calculated."}
  run_gvcf_processing: {type: boolean, doc: "gVCF will be generated. Requires: dbsnp_vcf,
      contamination_sites_bed, contamination_sites_mu, contamination_sites_ud, and
      wgs_evaluation_interval_list."}
  cutadapt_r1_adapter: {type: 'string?', doc: "If read1 reads have an adapter, provide
      regular 3' adapter sequence here to remove it from read1"}
  cutadapt_r2_adapter: {type: 'string?', doc: "If read2 reads have an adapter, provide
      regular 3' adapter sequence here to remove it from read2"}
  cutadapt_min_len: {type: 'int?', doc: "If adapter trimming, discard reads/read-pairs
      where the read length is less than this value. Set to 0 to turn off"}
  cutadapt_quality_base: {type: 'int?', doc: "If adapter trimming, use this value
      as the base quality score. Defaults to 33 but very old reads might need this
      value set to 64"}
  cutadapt_quality_cutoff: {type: 'string?', doc: "If adapter trimming, remove bases
      from the 3'/5' that fail to meet this cutoff value. If you specify a single
      cutoff value, the 3' end of each read is trimmed. If you specify two cutoff
      values separated by a comma, the first value will be trimmed from the 5' and
      the second value will be trimmed from the 3'"}
  min_alignment_score: {type: 'int?', default: 30, doc: "For BWA MEM, Don't output
      alignment with score lower than INT. This option only affects output."}
  samtools_split_max_memory: {type: 'int?', default: 36, doc: "GB of RAM to allocate
      to samtools split."}
  samtools_split_cores: {type: 'int?', default: 36, doc: "Minimum reserved number
      of CPU cores for samtools split."}
outputs:
  cram: {type: File, outputSource: sentieon_readwriter_bam_to_cram/output_reads, doc: "(Re)Aligned
      Reads File"}
  gvcf: {type: 'File?', outputSource: generate_gvcf/gvcf, doc: "Genomic VCF generated
      from the realigned alignment file."}
  verifybamid_output: {type: 'File?', outputSource: generate_gvcf/verifybamid_output,
    doc: "Ouput from VerifyBamID that is used to calculate contamination."}
  cutadapt_stats: {type: 'File[]?', outputSource: sentieon_bwa_mem_payloads/cutadapt_stats, doc: "Stats from Cutadapt activity on inputs."}
  bqsr_report: {type: File, outputSource: sentieon_bqsr/recal_table, doc: "Recalibration
      report from BQSR."}
  gvcf_calling_metrics: {type: 'File[]?', outputSource: generate_gvcf/gvcf_calling_metrics,
    doc: "General metrics for gVCF calling quality."}
  hs_metrics: {type: 'File?', outputSource: sentieon_hsmetrics/hs_output, doc: "Sentieon's
      Picard-like CollectHsMetrics metrics for the analysis of target-capture sequencing
      experiments."}
  wgs_metrics: {type: 'File?', outputSource: sentieon_wgsmetrics/wgs_output, doc: "Sentieon's
      Picard-like CollectWgsMetrics metrics for evaluating the performance of whole
      genome sequencing experiments."}
  alignment_metrics: {type: 'File?', outputSource: sentieon_aggmetrics/as_output,
    doc: "Sentieon's Picard-like CollectAlignmentSummaryMetrics high level metrics
      about the alignment of reads within a SAM file."}
  gc_bias_detail: {type: 'File?', outputSource: sentieon_aggmetrics/gc_bias_detail,
    doc: "Sentieon's Picard-like CollectGcBiasMetrics detailed metrics about reads
      that fall within windows of a certain GC bin on the reference genome."}
  gc_bias_summary: {type: 'File?', outputSource: sentieon_aggmetrics/gc_bias_summary,
    doc: "Sentieon's Picard-like CollectGcBiasMetrics high level metrics that capture
      how biased the coverage in a certain lane is."}
  gc_bias_chart: {type: 'File?', outputSource: sentieon_aggmetrics/gc_bias_chart,
    doc: "Sentieon's Picard-like CollectGcBiasMetrics plot of GC bias."}
  insert_metrics: {type: 'File?', outputSource: sentieon_aggmetrics/is_metrics, doc: "Sentieon's
      Picard-like CollectInsertSizeMetrics metrics about the insert size distribution
      of a paired-end library."}
  insert_plot: {type: 'File?', outputSource: sentieon_aggmetrics/is_plot, doc: "Sentieon's
      Picard-like CollectInsertSizeMetrics insert size distribution plotted."}
  artifact_bait_bias_detail_metrics: {type: 'File?', outputSource: sentieon_aggmetrics/sama_bait_bias_detail_metrics,
    doc: "Sentieon's Picard-like CollectSequencingArtifactMetrics bait bias artifacts
      broken down by context."}
  artifact_bait_bias_summary_metrics: {type: 'File?', outputSource: sentieon_aggmetrics/sama_bait_bias_summary_metrics,
    doc: "Sentieon's Picard-like CollectSequencingArtifactMetrics summary analysis
      of a single bait bias artifact."}
  artifact_error_summary_metrics: {type: 'File?', outputSource: sentieon_aggmetrics/sama_error_summary_metrics,
    doc: "Sentieon's Picard-like CollectSequencingArtifactMetrics summary metrics
      as a roll up of the context-specific error rates, to provide global error rates
      per type of base substitution."}
  artifact_pre_adapter_detail_metrics: {type: 'File?', outputSource: sentieon_aggmetrics/sama_pre_adapter_detail_metrics,
    doc: "Sentieon's Picard-like CollectSequencingArtifactMetrics pre-adapter artifacts
      broken down by context."}
  artifact_pre_adapter_summary_metrics: {type: 'File?', outputSource: sentieon_aggmetrics/sama_pre_adapter_summary_metrics,
    doc: "Sentieon's Picard-like CollectSequencingArtifactMetrics summary analysis
      of a single pre-adapter artifact."}
  qual_metrics: {type: 'File?', outputSource: sentieon_aggmetrics/qd_metrics, doc: "Quality
      metrics for the realigned CRAM."}
  qual_chart: {type: 'File?', outputSource: sentieon_aggmetrics/qd_chart, doc: "Visualization
      of quality metrics."}
  idxstats: {type: 'File?', outputSource: samtools_idxstats_xy_ratio/output, doc: "samtools
      idxstats of the realigned BAM file."}
  xy_ratio: {type: 'File?', outputSource: samtools_idxstats_xy_ratio/ratio, doc: "Text
      file containing X and Y reads statistics generated from idxstats."}
steps:
  untar_reference:
    run: ../tools/untar_indexed_reference_2.cwl
    in:
      reference_tar: reference_tar
    out: [indexed_fasta, dict]
  index_knownsites:
    run: ../tools/tabix_index.cwl
    in:
      input_file: knownsites
      input_index: knownsites_indexes
    scatter: [input_file, input_index]
    scatterMethod: dotproduct
    out: [output]
  samtools_split:
    run: ../tools/samtools_split.cwl
    when: $(inputs.input_bam != null)
    scatter: [input_bam]
    in:
      input_bam: input_bam_list
      reference:
        source: [cram_reference, untar_reference/indexed_fasta]
        pickValue: first_non_null
      max_memory: samtools_split_max_memory
      cores: samtools_split_cores
    out: [bam_files]
  flatten_split_rgbams:
    run: ../tools/clt_flatten_filelist.cwl
    when: $(inputs.input_files != null)
    in:
      input_files: samtools_split/bam_files
      max_memory: samtools_split_max_memory
      cores: samtools_split_cores
    out: [output_files]
  prepare_bam_bwa_payloads:
    hints:
    - class: "sbg:AWSInstanceType"
      value: c5.9xlarge
    run: ../subworkflows/rgbam_to_bwa_payload.cwl
    when: $(inputs.input_rgbam != null)
    scatter: [input_rgbam]
    in:
      input_rgbam: flatten_split_rgbams/output_files
      sample_name: biospecimen_name
      cram_reference: cram_reference
    out: [bwa_payload]
  prepare_pe_fq_bwa_payloads:
    run: ../tools/clt_prepare_bwa_payload.cwl
    when: $(inputs.reads != null)
    scatter: [reads, mates, rg_str]
    scatterMethod: dotproduct
    in:
      reads: input_pe_reads_list
      mates: input_pe_mates_list
      rg_str: input_pe_rgs_list
    out: [bwa_payload]
  prepare_se_fq_bwa_payloads:
    run: ../tools/clt_prepare_bwa_payload.cwl
    when: $(inputs.reads != null)
    scatter: [reads, rg_str]
    scatterMethod: dotproduct
    in:
      reads: input_se_reads_list
      rg_str: input_se_rgs_list
    out: [bwa_payload]
  sentieon_bwa_mem_payloads:
    run: ../subworkflows/bwa_payload_to_realn_bam.cwl
    when: $(inputs.bwa_payload != null)
    scatter: [bwa_payload]
    in:
      sentieon_license: sentieon_license
      indexed_reference_fasta: untar_reference/indexed_fasta
      output_basename: output_basename
      cutadapt_r1_adapter: cutadapt_r1_adapter
      cutadapt_r2_adapter: cutadapt_r2_adapter
      cutadapt_min_len: cutadapt_min_len
      cutadapt_quality_base: cutadapt_quality_base
      cutadapt_quality_cutoff: cutadapt_quality_cutoff
      min_alignment_score: min_alignment_score
      bwa_payload:
        source: [prepare_bam_bwa_payloads/bwa_payload, prepare_pe_fq_bwa_payloads/bwa_payload,
          prepare_se_fq_bwa_payloads/bwa_payload]
        linkMerge: merge_flattened
        pickValue: all_non_null
    out: [realgn_bam, cutadapt_stats]
  sentieon_readwriter_merge_bams:
    run: ../tools/sentieon_ReadWriter.cwl
    in:
      sentieon_license: sentieon_license
      reference: untar_reference/indexed_fasta
      input_bam: sentieon_bwa_mem_payloads/realgn_bam
      output_file_name:
        source: output_basename
        valueFrom: $(self).aligned.sorted.bam
    out: [output_reads]
  sentieon_markdups:
    run: ../tools/sentieon_dedup.cwl
    in:
      sentieon_license: sentieon_license
      reference: untar_reference/indexed_fasta
      in_alignments:
        source: sentieon_readwriter_merge_bams/output_reads
        valueFrom: |
          $(self ? [self] : self)
    out: [metrics_file, out_alignments]
  sentieon_bqsr:
    run: ../tools/sentieon_bqsr.cwl
    in:
      sentieon_license: sentieon_license
      reference: untar_reference/indexed_fasta
      input_bam: sentieon_markdups/out_alignments
      prefix: output_basename
      known_sites: index_knownsites/output
    out: [output_reads, recal_table]
  sentieon_readwriter_bam_to_cram:
    run: ../tools/sentieon_ReadWriter.cwl
    in:
      sentieon_license: sentieon_license
      reference: untar_reference/indexed_fasta
      input_bam:
        source: sentieon_bqsr/output_reads
        valueFrom: |
          $(self ? [self] : self)
      output_file_name:
        source: sentieon_bqsr/output_reads
        valueFrom: $(self.nameroot).cram
      rm_cram_bai:
        valueFrom: $(1 == 1)
    out: [output_reads]
  sentieon_hsmetrics:
    run: ../tools/sentieon_HsMetricAlgo.cwl
    when: $(inputs.conditional == true)
    in:
      sentieon_license: sentieon_license
      reference: untar_reference/indexed_fasta
      input_bam: sentieon_bqsr/output_reads
      targets_list: wxs_target_interval_list
      baits_list: wxs_bait_interval_list
      conditional: run_hs_metrics
    out: [hs_output]
  sentieon_wgsmetrics:
    run: ../tools/sentieon_WgsMetricsAlgo.cwl
    when: $(inputs.conditional == true)
    in:
      sentieon_license: sentieon_license
      reference: untar_reference/indexed_fasta
      input_bam: sentieon_bqsr/output_reads
      interval: wgs_coverage_interval_list
      conditional: run_wgs_metrics
    out: [wgs_output]
  sentieon_aggmetrics:
    run: ../tools/sentieon_run_agg_metrics.cwl
    when: $(inputs.conditional == true)
    in:
      sentieon_license: sentieon_license
      reference: untar_reference/indexed_fasta
      input_bam: sentieon_bqsr/output_reads
      accum_level_gc_bias:
        valueFrom: "SAMPLE,LIBRARY"
      conditional: run_agg_metrics
    out: [as_output, sama_bait_bias_detail_metrics, sama_bait_bias_summary_metrics,
      sama_error_summary_metrics, sama_oxog_metrics, sama_pre_adapter_detail_metrics,
      sama_pre_adapter_summary_metrics, bdbc_output, gc_bias_chart, gc_bias_detail,
      gc_bias_summary, is_metrics, is_plot, mqbc_output, mqbc_plot, qd_chart, qd_metrics,
      qy_output]
  samtools_idxstats_xy_ratio:
    run: ../tools/samtools_idxstats_xy_ratio.cwl
    in:
      run_idxstats: run_sex_metrics
      input_bam: sentieon_bqsr/output_reads
    out: [output, ratio]
  generate_gvcf:
    run: ../workflows/kfdrc_sentieon_gvcf_wf.cwl
    when: $(inputs.conditional != false)
    in:
      contamination_sites_bed: contamination_sites_bed
      contamination_sites_mu: contamination_sites_mu
      contamination_sites_ud: contamination_sites_ud
      input_reads: sentieon_bqsr/output_reads
      reference_tar: reference_tar
      output_basename: output_basename
      dbsnp_vcf: dbsnp_vcf
      dbsnp_idx: dbsnp_idx
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
      conditional: run_gvcf_processing
      run_sex_metrics:
        valueFrom: $(1 == 0)
    out: [verifybamid_output, gvcf, gvcf_calling_metrics, idxstats, xy_ratio]
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
- SENTIEON
"sbg:links":
- id: 'https://github.com/kids-first/kf-alignment-workflow/releases/tag/v2.10.0'
  label: github-release
