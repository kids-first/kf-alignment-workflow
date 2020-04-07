cwlVersion: v1.0
class: Workflow
id: kf_alignment_cyoa_wf
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  input_bam_list: 'File[]?'
  input_pe_reads_list: 'File[]?'
  input_pe_mates_list: 'File[]?'
  input_pe_rgs_list: 'string[]?'
  input_se_reads_list: 'File[]?'
  input_se_rgs_list: 'string[]?'
  indexed_reference_fasta:
    type: File
    secondaryFiles: ['.64.amb', '.64.ann', '.64.bwt', '.64.pac', '.64.sa', '.64.alt', '^.dict', '.amb', '.ann', '.bwt', '.pac', '.sa', '.fai']
  biospecimen_name: string
  output_basename: string
  reference_dict: File
  dbsnp_vcf: File
  knownsites: File[]
  contamination_sites_bed: 'File?'
  contamination_sites_mu: 'File?'
  contamination_sites_ud: 'File?'
  wgs_calling_interval_list: 'File?'
  wgs_coverage_interval_list: 'File?'
  wgs_evaluation_interval_list: 'File?'
  wxs_bait_interval_list: 'File?'
  wxs_target_interval_list: 'File?'
  run_bam_processing: boolean
  run_pe_reads_processing: boolean
  run_se_reads_processing: boolean
  run_hs_metrics: boolean
  run_wgs_metrics: boolean
  run_agg_metrics: boolean
  run_gvcf_processing: boolean

outputs:
  cram: {type: File, outputSource: samtools_coverttocram/output}
  gvcf: {type: 'File[]?', outputSource: generate_gvcf/gvcf}
  verifybamid_output: {type: 'File[]?', outputSource: generate_gvcf/verifybamid_output}
  bqsr_report: {type: File, outputSource: gatk_gatherbqsrreports/output}
  gvcf_calling_metrics: {type: ['null', { type: array , items: { type : array, items: File } } ], outputSource: generate_gvcf/gvcf_calling_metrics} 
  aggregation_metrics: {type: ['null', { type: array , items: { type : array, items: File } } ], outputSource: picard_collectaggregationmetrics/output}
  hs_metrics: {type: 'File[]?', outputSource: picard_collecthsmetrics/output}
  wgs_metrics: {type: 'File[]?', outputSource: picard_collectwgsmetrics/output}

steps:
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
    out: [scatter_bams,scatter_pe_reads,scatter_se_reads, scatter_gvcf, scatter_hs_metrics, scatter_wgs_metrics, scatter_agg_metrics]

  process_bams:
    run: ../subworkflows/kfdrc_process_bamlist.cwl
    in:
      input_bam_list: input_bam_list
      indexed_reference_fasta: indexed_reference_fasta
      sample_name: biospecimen_name 
      conditional_run: gatekeeper/scatter_bams
    scatter: conditional_run
    out: [unsorted_bams] #+2 Nesting File[][][]

  process_pe_reads:
    run: ../subworkflows/kfdrc_process_pe_readslist2.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      input_pe_reads_list: input_pe_reads_list
      input_pe_mates_list: input_pe_mates_list
      input_pe_rgs_list: input_pe_rgs_list
      conditional_run: gatekeeper/scatter_pe_reads
    scatter: conditional_run
    out: [unsorted_bams] #+0 Nesting File[]

  process_se_reads:
    run: ../subworkflows/kfdrc_process_se_readslist2.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      input_se_reads_list: input_se_reads_list
      input_se_rgs_list: input_se_rgs_list
      conditional_run: gatekeeper/scatter_se_reads
    scatter: conditional_run
    out: [unsorted_bams] #+0 Nesting File[]

  sambamba_merge:
    hints:
      - class: sbg:AWSInstanceType
        value: c5.9xlarge;ebs-gp2;2048
    run: ../tools/sambamba_merge_anylist.cwl
    in:
      bams:
        source: [process_bams/unsorted_bams, process_pe_reads/unsorted_bams, process_se_reads/unsorted_bams]
        linkMerge: merge_flattened #Flattens all to File[]
      base_file_name: output_basename
    out: [merged_bam]

  sambamba_sort:
    hints:
      - class: sbg:AWSInstanceType
        value: c5.9xlarge;ebs-gp2;2048
    run: ../tools/sambamba_sort.cwl
    in:
      bam: sambamba_merge/merged_bam
      base_file_name: output_basename
    out: [sorted_bam]

  python_createsequencegroups:
    run: ../tools/python_createsequencegroups.cwl
    in:
      ref_dict: reference_dict
    out: [sequence_intervals, sequence_intervals_with_unmapped]

  gatk_baserecalibrator:
    run: ../tools/gatk_baserecalibrator.cwl
    in:
      input_bam: sambamba_sort/sorted_bam 
      knownsites: knownsites
      reference: indexed_reference_fasta
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
      reference: indexed_reference_fasta
      sequence_interval: python_createsequencegroups/sequence_intervals_with_unmapped
    scatter: [sequence_interval]
    out: [recalibrated_bam]

  picard_gatherbamfiles:
    run: ../tools/picard_gatherbamfiles.cwl
    in:
      input_bam: gatk_applybqsr/recalibrated_bam
      output_bam_basename: output_basename
    out: [output]

  samtools_coverttocram:
    run: ../tools/samtools_covert_to_cram.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: indexed_reference_fasta
    out: [output]

  picard_collecthsmetrics:
    run: ../tools/picard_collecthsmetrics_conditional.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      bait_intervals: wxs_bait_interval_list
      target_intervals: wxs_target_interval_list
      reference: indexed_reference_fasta
      conditional_run: gatekeeper/scatter_hs_metrics
    scatter: conditional_run
    out: [output]

  picard_collectwgsmetrics:
    run: ../tools/picard_collectwgsmetrics_conditional.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      intervals: wgs_coverage_interval_list
      reference: indexed_reference_fasta
      conditional_run: gatekeeper/scatter_wgs_metrics
    scatter: conditional_run
    out: [output]

  picard_collectaggregationmetrics:
    run: ../tools/picard_collectaggregationmetrics_conditional.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: indexed_reference_fasta
      conditional_run: gatekeeper/scatter_agg_metrics
    scatter: conditional_run
    out: [output]

  generate_gvcf:
    run: ../subworkflows/kfdrc_bam_to_gvcf.cwl
    in:
      contamination_sites_bed: contamination_sites_bed 
      contamination_sites_mu: contamination_sites_mu
      contamination_sites_ud: contamination_sites_ud
      input_bam: picard_gatherbamfiles/output
      indexed_reference_fasta: indexed_reference_fasta
      output_basename: output_basename
      dbsnp_vcf: dbsnp_vcf
      reference_dict: reference_dict
      wgs_calling_interval_list: wgs_calling_interval_list
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
      conditional_run: gatekeeper/scatter_gvcf
    scatter: conditional_run
    out: [verifybamid_output, gvcf, gvcf_calling_metrics]
    

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
