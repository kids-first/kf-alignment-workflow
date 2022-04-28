cwlVersion: v1.2
class: Workflow
id: kfdrc-sentieon-alignment-workflow
label: Kids First DRC Sentieon Alignment and GATK HaplotypeCaller Workflow
doc: |
  # Kids First Data Resource Center Sentieon Alignment and GATK HaplotypeCaller Workflows

  ![data service logo](https://github.com/d3b-center/d3b-research-workflows/raw/master/doc/kfdrc-logo-sm.png)

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  sentieon_license: { type: string, doc: "License server host and port" }
  input_bam_list: {type: 'File[]?', doc: "List of input BAM files"}
  input_pe_reads_list: {type: 'File[]?', doc: "List of input R1 paired end fastq reads"}
  input_pe_mates_list: {type: 'File[]?', doc: "List of input R2 paired end fastq reads"}
  input_pe_rgs_list: {type: 'string[]?', doc: "List of RG strings to use in PE processing"}
  input_se_reads_list: {type: 'File[]?', doc: "List of input singlie end fastq reads"}
  input_se_rgs_list: {type: 'string[]?', doc: "List of RG strings to use in SE processing"}
  reference_tar: {type: File, doc: "Tar file containing a reference fasta and, optionally,\
      \ its complete set of associated indexes (samtools, bwa, and picard)", "sbg:suggestedValue": {
      class: File, path: 5f4ffff4e4b0370371c05153, name: Homo_sapiens_assembly38.tgz}}
  biospecimen_name: {type: string, doc: "String name of biospcimen"}
  output_basename: {type: string, doc: "String to use as the base for output filenames"}
  dbsnp_vcf: {type: 'File?', doc: "dbSNP vcf file", "sbg:suggestedValue": {class: File,
      path: 6063901f357c3a53540ca84b, name: Homo_sapiens_assembly38.dbsnp138.vcf}}
  dbsnp_idx: {type: 'File?', doc: "dbSNP vcf index file", "sbg:suggestedValue": {class: File,
      path: 6063901e357c3a53540ca834, name: Homo_sapiens_assembly38.dbsnp138.vcf.idx}}
  knownsites: {type: 'File[]', doc: "List of files containing known polymorphic sites\
      \ used to exclude regions around known polymorphisms from analysis", "sbg:suggestedValue": [
      {class: File, path: 6063901e357c3a53540ca835, name: 1000G_omni2.5.hg38.vcf.gz},
      {class: File, path: 6063901c357c3a53540ca80f, name: 1000G_phase1.snps.high_confidence.hg38.vcf.gz},
      {class: File, path: 60639017357c3a53540ca7d0, name: Homo_sapiens_assembly38.known_indels.vcf.gz},
      {class: File, path: 6063901a357c3a53540ca7f3, name: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz}]}
  knownsites_indexes: {type: 'File[]?', doc: "Corresponding indexes for the knownsites.\
      \ File position in list must match with its corresponding VCF's position in\
      \ the knownsites file list. For example, if the first file in the knownsites\
      \ list is 1000G_omni2.5.hg38.vcf.gz then the first item in this list must be\
      \ 1000G_omni2.5.hg38.vcf.gz.tbi. Optional, but will save time/cost on indexing.",
    "sbg:suggestedValue": [{class: File, path: 60639016357c3a53540ca7b1, name: 1000G_omni2.5.hg38.vcf.gz.tbi},
      {class: File, path: 6063901e357c3a53540ca845, name: 1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi},
      {class: File, path: 6063901c357c3a53540ca80d, name: Homo_sapiens_assembly38.known_indels.vcf.gz.tbi},
      {class: File, path: 6063901c357c3a53540ca806, name: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi}]}
  contamination_sites_bed: {type: 'File?', doc: ".bed file for markers used in this\
      \ analysis,format(chr\tpos-1\tpos\trefAllele\taltAllele)", "sbg:suggestedValue": {
      class: File, path: 6063901e357c3a53540ca833, name: Homo_sapiens_assembly38.contam.bed}}
  contamination_sites_mu: {type: 'File?', doc: ".mu matrix file of genotype matrix",
    "sbg:suggestedValue": {class: File, path: 60639017357c3a53540ca7cd, name: Homo_sapiens_assembly38.contam.mu}}
  contamination_sites_ud: {type: 'File?', doc: ".UD matrix file from SVD result of\
      \ genotype matrix", "sbg:suggestedValue": {class: File, path: 6063901f357c3a53540ca84f,
      name: Homo_sapiens_assembly38.contam.UD}}
  wgs_calling_interval_list: {type: 'File?', doc: "WGS interval list used to aid scattering\
      \ Haplotype caller", "sbg:suggestedValue": {class: File, path: 60639018357c3a53540ca7df,
      name: wgs_calling_regions.hg38.interval_list}}
  wgs_coverage_interval_list: {type: 'File?', doc: "An interval list file that contains\
      \ the positions to restrict the wgs metrics assessment", "sbg:suggestedValue": {
      class: File, path: 6063901c357c3a53540ca813, name: wgs_coverage_regions.hg38.interval_list}}
  wgs_evaluation_interval_list: {type: 'File?', doc: "Target intervals to restrict\
      \ gvcf metric analysis (for VariantCallingMetrics)", "sbg:suggestedValue": {class: File,
      path: 60639017357c3a53540ca7d3, name: wgs_evaluation_regions.hg38.interval_list}}
  wxs_bait_interval_list: {type: 'File?', doc: "An interval list file that contains\
      \ the locations of the WXS baits used (for HsMetrics)"}
  wxs_target_interval_list: {type: 'File?', doc: "An interval list file that contains\
      \ the locations of the WXS targets (for HsMetrics)"}
  run_bam_processing: {type: boolean, doc: "BAM processing will be run. Requires:\
      \ input_bam_list"}
  run_pe_reads_processing: {type: boolean, doc: "PE reads processing will be run.\
      \ Requires: input_pe_reads_list, input_pe_mates_list, input_pe_rgs_list"}
  run_se_reads_processing: {type: boolean, doc: "SE reads processing will be run.\
      \ Requires: input_se_reads_list, input_se_rgs_list"}
  run_hs_metrics: {type: boolean, doc: "HsMetrics will be collected. Only recommended\
      \ for WXS inputs. Requires: wxs_bait_interval_list, wxs_target_interval_list"}
  run_wgs_metrics: {type: boolean, doc: "WgsMetrics will be collected. Only recommended\
      \ for WGS inputs. Requires: wgs_coverage_interval_list"}
  run_agg_metrics: {type: boolean, doc: "AlignmentSummaryMetrics, GcBiasMetrics, InsertSizeMetrics,\
      \ QualityScoreDistribution, and SequencingArtifactMetrics will be collected.\
      \ Recommended for both WXS and WGS inputs."}
  run_sex_metrics: {type: boolean, doc: "idxstats will be collected and X/Y ratios\
      \ calculated"}
  run_gvcf_processing: {type: boolean, doc: "gVCF will be generated. Requires: dbsnp_vcf,\
      \ contamination_sites_bed, contamination_sites_mu, contamination_sites_ud, wgs_calling_interval_list,\
      \ wgs_evaluation_interval_list"}
  min_alignment_score: {type: 'int?', default: 30, doc: "For BWA MEM, Don't output\
      \ alignment with score lower than INT. This option only affects output."}

outputs:
  cram: {type: File, outputSource: sentieon_readwriter_bam_to_cram/output_reads, doc: "(Re)Aligned\
      \ Reads File"}
  gvcf: {type: 'File[]?', outputSource: generate_gvcf/gvcf, doc: "Genomic VCF generated\
      \ from the realigned alignment file."}
  verifybamid_output: {type: 'File[]?', outputSource: generate_gvcf/verifybamid_output,
    doc: "Ouput from VerifyBamID that is used to calculate contamination."}
  bqsr_report: {type: File, outputSource: gatk_gatherbqsrreports/output, doc: "Recalibration\
      \ report from BQSR."}
  gvcf_calling_metrics: {type: ['null', {type: array, items: {type: array, items: File}}],
    outputSource: generate_gvcf/gvcf_calling_metrics, doc: "General metrics for gVCF\
      \ calling quality."}
  hs_metrics: {type: 'File?', outputSource: sentieon_hsmetrics/hs_output, doc: "Picard\
      \ CollectHsMetrics metrics for the analysis of target-capture sequencing experiments."}
  wgs_metrics: {type: 'File?', outputSource: sentieon_wgsmetrics/wgs_output, doc: "Picard\
      \ CollectWgsMetrics metrics for evaluating the performance of whole genome sequencing\
      \ experiments."}
  alignment_metrics: {type: 'File?', outputSource: sentieon_aggmetrics/as_output,
    doc: "Picard CollectAlignmentSummaryMetrics high level metrics about the alignment\
      \ of reads within a SAM file."}
  gc_bias_detail: {type: 'File?', outputSource: sentieon_aggmetrics/gc_bias_detail,
    doc: "Picard CollectGcBiasMetrics detailed metrics about reads that fall within\
      \ windows of a certain GC bin on the reference genome."}
  gc_bias_summary: {type: 'File?', outputSource: sentieon_aggmetrics/gc_bias_summary,
    doc: "Picard CollectGcBiasMetrics high level metrics that capture how biased the\
      \ coverage in a certain lane is."}
  gc_bias_chart: {type: 'File?', outputSource: sentieon_aggmetrics/gc_bias_chart,
    doc: "Picard CollectGcBiasMetrics plot of GC bias."}
  insert_metrics: {type: 'File?', outputSource: sentieon_aggmetrics/is_metrics,
    doc: "Picard CollectInsertSizeMetrics metrics about the insert size distribution\
      \ of a paired-end library."}
  insert_plot: {type: 'File?', outputSource: sentieon_aggmetrics/is_plot,
    doc: "Picard CollectInsertSizeMetrics insert size distribution plotted."}
  artifact_bait_bias_detail_metrics: {type: 'File?', outputSource: sentieon_aggmetrics/sama_bait_bias_detail_metrics,
    doc: "Picard CollectSequencingArtifactMetrics bait bias artifacts broken down\
      \ by context."}
  artifact_bait_bias_summary_metrics: {type: 'File?', outputSource: sentieon_aggmetrics/sama_bait_bias_summary_metrics,
    doc: "Picard CollectSequencingArtifactMetrics summary analysis of a single bait\
      \ bias artifact."}
  artifact_error_summary_metrics: {type: 'File?', outputSource: sentieon_aggmetrics/sama_error_summary_metrics,
    doc: "Picard CollectSequencingArtifactMetrics summary metrics as a roll up of\
      \ the context-specific error rates, to provide global error rates per type of\
      \ base substitution."}
  artifact_pre_adapter_detail_metrics: {type: 'File?', outputSource: sentieon_aggmetrics/sama_pre_adapter_detail_metrics,
    doc: "Picard CollectSequencingArtifactMetrics pre-adapter artifacts broken down\
      \ by context."}
  artifact_pre_adapter_summary_metrics: {type: 'File?', outputSource: sentieon_aggmetrics/sama_pre_adapter_summary_metrics,
    doc: "Picard CollectSequencingArtifactMetrics summary analysis of a single pre-adapter\
      \ artifact."}
  qual_metrics: {type: 'File?', outputSource: sentieon_aggmetrics/qd_metrics,
    doc: "Quality metrics for the realigned CRAM."}
  qual_chart: {type: 'File?', outputSource: sentieon_aggmetrics/qd_chart,
    doc: "Visualization of quality metrics."}
  idxstats: {type: 'File?', outputSource: samtools_idxstats_xy_ratio/output, doc: "samtools\
      \ idxstats of the realigned BAM file."}
  xy_ratio: {type: 'File?', outputSource: samtools_idxstats_xy_ratio/ratio, doc: "Text\
      \ file containing X and Y reads statistics generated from idxstats."}

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
    out: [scatter_bams, scatter_pe_reads, scatter_se_reads, scatter_gvcf, scatter_hs_metrics,
      scatter_wgs_metrics, scatter_agg_metrics]

  samtools_split:
    run: ../tools/samtools_split.cwl
    when: $(inputs.input_bam != null)
    scatter: [input_bam]
    in:
      input_bam: input_bam_list
      reference: untar_reference/indexed_fasta
    out: [bam_files]

  flatten_split_rgbams:
    run: ../tools/clt_flatten_filelist.cwl
    when: $(inputs.input_files != null)
    in:
      input_files: samtools_split/bam_files
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
      min_alignment_score: min_alignment_score
      bwa_payload:
        source: [prepare_bam_bwa_payloads/bwa_payload, prepare_pe_fq_bwa_payloads/bwa_payload, prepare_se_fq_bwa_payloads/bwa_payload]
        linkMerge: merge_flattened
        pickValue: all_non_null
    out: [realgn_bam]

  sentieon_readwriter_merge_bams:
    run: ../tools/sentieon_ReadWriter.cwl
    in:
      sentieon_license: sentieon_license
      reference: untar_reference/indexed_fasta
      input_bam: sentieon_bwa_mem_payloads/realgn_bam
      output_file_name:
        source: output_basename
        valueFrom: $(self+".aligned.sorted.bam")
    out: [output_reads]

  sentieon_markdups:
    run: ../tools/sentieon_dedup.cwl
    in:
      sentieon_license: sentieon_license
      reference: untar_reference/indexed_fasta
      in_alignments:
        source: sentieon_readwriter_merge_bams/output_reads
        valueFrom: $([self])
    out: [metrics_file, out_alignments]

  python_createsequencegroups:
    run: ../tools/python_createsequencegroups.cwl
    in:
      ref_dict: untar_reference/dict
    out: [sequence_intervals, sequence_intervals_with_unmapped]

  gatk_baserecalibrator:
    run: ../tools/gatk_baserecalibrator.cwl
    in:
      input_bam: sentieon_markdups/out_alignments
      knownsites: index_knownsites/output
      reference: untar_reference/indexed_fasta
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
      input_bam: sentieon_markdups/out_alignments
      reference: untar_reference/indexed_fasta
      sequence_interval: python_createsequencegroups/sequence_intervals_with_unmapped
    scatter: [sequence_interval]
    out: [recalibrated_bam]

  picard_gatherbamfiles:
    run: ../tools/picard_gatherbamfiles.cwl
    in:
      input_bam: gatk_applybqsr/recalibrated_bam
      output_bam_basename: output_basename
    out: [output]

  sentieon_readwriter_bam_to_cram:
    run: ../tools/sentieon_ReadWriter.cwl
    in:
      sentieon_license: sentieon_license
      reference: untar_reference/indexed_fasta
      input_bam:
        source: picard_gatherbamfiles/output
        valueFrom: $([self])
      output_file_name:
        source: picard_gatherbamfiles/output
        valueFrom: $(self.nameroot+".cram")
    out: [output_reads]

  sentieon_hsmetrics:
    run: ../tools/sentieon_HsMetricAlgo.cwl
    when: $(inputs.conditional == true)
    in:
      sentieon_license: sentieon_license
      reference: untar_reference/indexed_fasta
      input_bam: picard_gatherbamfiles/output
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
      input_bam: picard_gatherbamfiles/output
      interval: wgs_coverage_interval_list
      conditional: run_wgs_metrics
    out: [wgs_output]

  sentieon_aggmetrics:
    run: ../tools/sentieon_run_agg_metrics.cwl
    when: $(inputs.conditional == true)
    in:
      sentieon_license: sentieon_license
      reference: untar_reference/indexed_fasta
      input_bam: picard_gatherbamfiles/output
      accum_level_gc_bias:
        valueFrom: "SAMPLE,LIBRARY"
      conditional: run_agg_metrics
    out: [as_output, sama_bait_bias_detail_metrics, sama_bait_bias_summary_metrics, sama_error_summary_metrics, sama_oxog_metrics, sama_pre_adapter_detail_metrics, sama_pre_adapter_summary_metrics, bdbc_output, gc_bias_chart, gc_bias_detail, gc_bias_summary, is_metrics, is_plot, mqbc_output, mqbc_plot, qd_chart, qd_metrics, qy_output]

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
      indexed_reference_fasta: untar_reference/indexed_fasta
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
  value: 6
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
- id: 'https://github.com/kids-first/kf-alignment-workflow/releases/tag/v2.7.4'
  label: github-release
