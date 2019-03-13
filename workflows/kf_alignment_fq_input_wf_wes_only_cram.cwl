cwlVersion: v1.0
class: Workflow
id: kf_alignment_fq_input_wf_wes
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  files_R1: File[]
  files_R2: File[]
  rgs: string[]
  output_basename: string
  indexed_reference_fasta: File
  knownsites: File[]
  reference_dict: File
  intervals: File

outputs:
  cram: {type: File, outputSource: samtools_coverttocram/output}
  bqsr_report: {type: File, outputSource: gatk_gatherbqsrreports/output}
  aggregation_metrics: {type: 'File[]', outputSource: picard_collectaggregationmetrics/output}
  hs_metrics: {type: File, outputSource: picard_collecthsmetrics/output}

steps:
  bwa_mem:
    run: ../tools/bwa_mem_fq.cwl
    in:
      file_R1: files_R1
      file_R2: files_R2
      rg: rgs
      ref: indexed_reference_fasta
    scatter: [file_R1, file_R2, rg]
    scatterMethod: dotproduct
    out: [output]
    
  sambamba_merge:
    run: ../tools/sambamba_merge_one.cwl
    in:
      bams: bwa_mem/output
      base_file_name: output_basename
    out: [merged_bam]

  sambamba_sort:
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

  picard_collectaggregationmetrics:
    run: ../tools/picard_collectaggregationmetrics.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: indexed_reference_fasta
    out: [output]

  picard_collecthsmetrics:
    run: ../tools/picard_collecthsmetrics.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      intervals: intervals
      reference: indexed_reference_fasta
    out: [output]

  samtools_coverttocram:
    run: ../tools/samtools_covert_to_cram.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: indexed_reference_fasta
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4

