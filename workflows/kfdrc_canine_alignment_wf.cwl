cwlVersion: v1.2
class: Workflow
id: kfdrc-canine-alignment-workflow
label: Kids First DRC Canine Alignment and GATK HaplotypeCaller Workflow
doc: |
  # Kids First Data Resource Center Alignment and GATK HaplotypeCaller Workflows

  ![data service logo](https://github.com/d3b-center/d3b-research-workflows/raw/master/doc/kfdrc-logo-sm.png)

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
  reference_tar: {type: File, doc: "Tar file containing a reference fasta and, optionally,\
      \ its complete set of associated indexes (samtools, bwa, and picard)", "sbg:suggestedValue": {
      class: File, path: 5f4ffff4e4b0370371c05153, name: Homo_sapiens_assembly38.tgz}}
  biospecimen_name: {type: string, doc: "String name of biospcimen"}
  output_basename: {type: string, doc: "String to use as the base for output filenames"}
  dbsnp_vcf: {type: 'File?', doc: "dbSNP vcf file", "sbg:suggestedValue": {class: File,
      path: 6063901f357c3a53540ca84b, name: Homo_sapiens_assembly38.dbsnp138.vcf}}
  dbsnp_idx: {type: 'File?', doc: "dbSNP vcf index file", "sbg:suggestedValue": {class: File,
      path: 6063901e357c3a53540ca834, name: Homo_sapiens_assembly38.dbsnp138.vcf.idx}}
  knownsites: {type: 'File[]?', doc: "List of files containing known polymorphic sites\
      \ used to exclude regions around known polymorphisms from analysis. If no files given, BQSR will be skipped", "sbg:suggestedValue": [
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
  cram: {type: File, outputSource: samtools_bam_to_cram/output, doc: "(Re)Aligned\
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
  hs_metrics: {type: 'File[]?', outputSource: picard_collecthsmetrics/output, doc: "Picard\
      \ CollectHsMetrics metrics for the analysis of target-capture sequencing experiments."}
  wgs_metrics: {type: 'File[]?', outputSource: picard_collectwgsmetrics/output, doc: "Picard\
      \ CollectWgsMetrics metrics for evaluating the performance of whole genome sequencing\
      \ experiments."}
  alignment_metrics: {type: 'File[]?', outputSource: picard_collectalignmentsummarymetrics/output,
    doc: "Picard CollectAlignmentSummaryMetrics high level metrics about the alignment\
      \ of reads within a SAM file."}
  gc_bias_detail: {type: 'File[]?', outputSource: picard_collectgcbiasmetrics/detail,
    doc: "Picard CollectGcBiasMetrics detailed metrics about reads that fall within\
      \ windows of a certain GC bin on the reference genome."}
  gc_bias_summary: {type: 'File[]?', outputSource: picard_collectgcbiasmetrics/summary,
    doc: "Picard CollectGcBiasMetrics high level metrics that capture how biased the\
      \ coverage in a certain lane is."}
  gc_bias_chart: {type: 'File[]?', outputSource: picard_collectgcbiasmetrics/chart,
    doc: "Picard CollectGcBiasMetrics plot of GC bias."}
  insert_metrics: {type: 'File[]?', outputSource: picard_collectinsertsizemetrics/metrics,
    doc: "Picard CollectInsertSizeMetrics metrics about the insert size distribution\
      \ of a paired-end library."}
  insert_plot: {type: 'File[]?', outputSource: picard_collectinsertsizemetrics/plot,
    doc: "Picard CollectInsertSizeMetrics insert size distribution plotted."}
  artifact_bait_bias_detail_metrics: {type: 'File[]?', outputSource: picard_collectsequencingartifactmetrics/bait_bias_detail_metrics,
    doc: "Picard CollectSequencingArtifactMetrics bait bias artifacts broken down\
      \ by context."}
  artifact_bait_bias_summary_metrics: {type: 'File[]?', outputSource: picard_collectsequencingartifactmetrics/bait_bias_summary_metrics,
    doc: "Picard CollectSequencingArtifactMetrics summary analysis of a single bait\
      \ bias artifact."}
  artifact_error_summary_metrics: {type: 'File[]?', outputSource: picard_collectsequencingartifactmetrics/error_summary_metrics,
    doc: "Picard CollectSequencingArtifactMetrics summary metrics as a roll up of\
      \ the context-specific error rates, to provide global error rates per type of\
      \ base substitution."}
  artifact_pre_adapter_detail_metrics: {type: 'File[]?', outputSource: picard_collectsequencingartifactmetrics/pre_adapter_detail_metrics,
    doc: "Picard CollectSequencingArtifactMetrics pre-adapter artifacts broken down\
      \ by context."}
  artifact_pre_adapter_summary_metrics: {type: 'File[]?', outputSource: picard_collectsequencingartifactmetrics/pre_adapter_summary_metrics,
    doc: "Picard CollectSequencingArtifactMetrics summary analysis of a single pre-adapter\
      \ artifact."}
  qual_metrics: {type: 'File[]?', outputSource: picard_qualityscoredistribution/metrics,
    doc: "Quality metrics for the realigned CRAM."}
  qual_chart: {type: 'File[]?', outputSource: picard_qualityscoredistribution/chart,
    doc: "Visualization of quality metrics."}
  idxstats: {type: 'File?', outputSource: samtools_idxstats_xy_ratio/output, doc: "samtools\
      \ idxstats of the realigned BAM file."}
  xy_ratio: {type: 'File?', outputSource: samtools_idxstats_xy_ratio/ratio, doc: "Text\
      \ file containing X and Y reads statistics generated from idxstats."}

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
        source: [untar_reference/fai, untar_reference/dict, untar_reference/alt, untar_reference/amb,
          untar_reference/ann, untar_reference/bwt, untar_reference/pac, untar_reference/sa]
        linkMerge: merge_flattened
    out: [output]

  index_knownsites:
    run: ../tools/tabix_index.cwl
    when: $(inputs.knownsites != null)
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

  process_bams:
    run: ../subworkflows/kfdrc_process_bamlist.cwl
    in:
      input_bam_list: input_bam_list
      indexed_reference_fasta: bundle_secondaries/output
      sample_name: biospecimen_name
      conditional_run: gatekeeper/scatter_bams
      min_alignment_score: min_alignment_score
    scatter: conditional_run
    out: [unsorted_bams] #+2 Nesting File[][][]

  process_pe_reads:
    run: ../subworkflows/kfdrc_process_pe_readslist2.cwl
    in:
      indexed_reference_fasta: bundle_secondaries/output
      input_pe_reads_list: input_pe_reads_list
      input_pe_mates_list: input_pe_mates_list
      input_pe_rgs_list: input_pe_rgs_list
      conditional_run: gatekeeper/scatter_pe_reads
      min_alignment_score: min_alignment_score
    scatter: conditional_run
    out: [unsorted_bams] #+0 Nesting File[]

  process_se_reads:
    run: ../subworkflows/kfdrc_process_se_readslist2.cwl
    in:
      indexed_reference_fasta: bundle_secondaries/output
      input_se_reads_list: input_se_reads_list
      input_se_rgs_list: input_se_rgs_list
      conditional_run: gatekeeper/scatter_se_reads
      min_alignment_score: min_alignment_score
    scatter: conditional_run
    out: [unsorted_bams] #+0 Nesting File[]

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
    when: $(inputs.knownsites != null)
    in:
      input_bam: sambamba_sort/sorted_bam
      knownsites: index_knownsites/output
      reference: bundle_secondaries/output
      sequence_interval: python_createsequencegroups/sequence_intervals
    scatter: [sequence_interval]
    out: [output]

  gatk_gatherbqsrreports:
    run: ../tools/gatk_gatherbqsrreports.cwl
    when: $(inputs.knownsites != null)
    in:
      input_brsq_reports: gatk_baserecalibrator/output
      output_basename: output_basename
    out: [output]

  gatk_applybqsr:
    run: ../tools/gatk_applybqsr.cwl
    when: $(inputs.knownsites != null)
    in:
      bqsr_report: gatk_gatherbqsrreports/output
      input_bam: sambamba_sort/sorted_bam
      reference: bundle_secondaries/output
      sequence_interval: python_createsequencegroups/sequence_intervals_with_unmapped
    scatter: [sequence_interval]
    out: [recalibrated_bam]

  picard_gatherbamfiles:
    run: ../tools/picard_gatherbamfiles.cwl
    when: $(inputs.knownsites != null)
    in:
      input_bam: gatk_applybqsr/recalibrated_bam
      output_bam_basename: output_basename
    out: [output]

  samtools_bam_to_cram:
    run: ../tools/samtools_bam_to_cram.cwl
    in:
      input_bam:
        source: [picard_gatherbamfiles/output, sambamba_sort/sorted_bam]
        pickValue: first_non_null
      reference: bundle_secondaries/output
    out: [output]

  picard_collecthsmetrics:
    run: ../tools/picard_collecthsmetrics_conditional.cwl
    in:
      input_bam:
        source: [picard_gatherbamfiles/output, sambamba_sort/sorted_bam]
        pickValue: first_non_null
      bait_intervals: wxs_bait_interval_list
      target_intervals: wxs_target_interval_list
      reference: bundle_secondaries/output
      conditional_run: gatekeeper/scatter_hs_metrics
    scatter: conditional_run
    out: [output]

  picard_collectwgsmetrics:
    run: ../tools/picard_collectwgsmetrics_conditional.cwl
    in:
      input_bam:
        source: [picard_gatherbamfiles/output, sambamba_sort/sorted_bam]
        pickValue: first_non_null
      intervals: wgs_coverage_interval_list
      reference: bundle_secondaries/output
      conditional_run: gatekeeper/scatter_wgs_metrics
    scatter: conditional_run
    out: [output]

  picard_collectalignmentsummarymetrics:
    run: ../tools/picard_collectalignmentsummarymetrics_conditional.cwl
    in:
      input_bam:
        source: [picard_gatherbamfiles/output, sambamba_sort/sorted_bam]
        pickValue: first_non_null
      reference: bundle_secondaries/output
      conditional_run: gatekeeper/scatter_agg_metrics
    scatter: conditional_run
    out: [output]

  picard_collectgcbiasmetrics:
    run: ../tools/picard_collectgcbiasmetrics_conditional.cwl
    in:
      input_bam:
        source: [picard_gatherbamfiles/output, sambamba_sort/sorted_bam]
        pickValue: first_non_null
      reference: bundle_secondaries/output
      conditional_run: gatekeeper/scatter_agg_metrics
    scatter: conditional_run
    out: [detail, summary, chart]

  picard_collectinsertsizemetrics:
    run: ../tools/picard_collectinsertsizemetrics_conditional.cwl
    in:
      input_bam:
        source: [picard_gatherbamfiles/output, sambamba_sort/sorted_bam]
        pickValue: first_non_null
      reference: bundle_secondaries/output
      conditional_run: gatekeeper/scatter_agg_metrics
    scatter: conditional_run
    out: [metrics, plot]

  picard_collectsequencingartifactmetrics:
    run: ../tools/picard_collectsequencingartifactmetrics_conditional.cwl
    in:
      input_bam:
        source: [picard_gatherbamfiles/output, sambamba_sort/sorted_bam]
        pickValue: first_non_null
      reference: bundle_secondaries/output
      conditional_run: gatekeeper/scatter_agg_metrics
    scatter: conditional_run
    out: [bait_bias_detail_metrics, bait_bias_summary_metrics, error_summary_metrics,
      pre_adapter_detail_metrics, pre_adapter_summary_metrics]

  picard_qualityscoredistribution:
    run: ../tools/picard_qualityscoredistribution_conditional.cwl
    in:
      input_bam:
        source: [picard_gatherbamfiles/output, sambamba_sort/sorted_bam]
        pickValue: first_non_null
      reference: bundle_secondaries/output
      conditional_run: gatekeeper/scatter_agg_metrics
    scatter: conditional_run
    out: [metrics, chart]

  samtools_idxstats_xy_ratio:
    run: ../tools/samtools_idxstats_xy_ratio.cwl
    in:
      run_idxstats: run_sex_metrics
      input_bam:
        source: [picard_gatherbamfiles/output, sambamba_sort/sorted_bam]
        pickValue: first_non_null
    out: [output, ratio]

  generate_gvcf:
    run: ../subworkflows/kfdrc_bam_to_gvcf.cwl
    in:
      biospecimen_name: biospecimen_name
      contamination_sites_bed: contamination_sites_bed
      contamination_sites_mu: contamination_sites_mu
      contamination_sites_ud: contamination_sites_ud
      input_bam:
        source: [picard_gatherbamfiles/output, sambamba_sort/sorted_bam]
        pickValue: first_non_null
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
  value: 6
"sbg:license": Apache License 2.0
"sbg:publisher": KFDRC
"sbg:categories":
- ALIGNMENT
- DNA
- WGS
- WXS
- GVCF
"sbg:links":
- id: 'https://github.com/kids-first/kf-alignment-workflow/releases/tag/v2.7.4'
  label: github-release
