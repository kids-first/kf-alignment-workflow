cwlVersion: v1.0
class: Workflow
id: scatter_bqsr
requirements:
  - class: ScatterFeatureRequirement

inputs:
  input_bam: File
  indexed_reference_fasta: File
  base_file_name: string
  knownsites: File[]
  sequence_grouping_tsv: File

outputs:
  duplicates_marked_bam:
    type: File
    outputSource: picard_markduplicates/output_markduplicates_bam
  sorted_bam:
    type: File
    outputSource: picard_sortsam/output_sorted_bam
  bqsr_report:
    type: File
    outputSource: gatk_gatherbqsrreports/output

steps:
  picard_revertsam:
    run: ../tools/picard_revertsam.cwl
    in:
      input_bam: input_bam
    out: [output]

  bwa_mem:
    run: ../tools/bwa_mem.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      input_bam: picard_revertsam/output
    scatter: [input_bam]
    out: [output]

  picard_markduplicates:
    run: ../tools/picard_markduplicates.cwl
    in:
      base_file_name: base_file_name
      input_bams: bwa_mem/output
    out: [output_markduplicates_bam]

  picard_sortsam:
    run: ../tools/picard_sortsam.cwl
    in:
      base_file_name: base_file_name
      input_bam: picard_markduplicates/output_markduplicates_bam
    out: [output_sorted_bam]

  createsequencegrouping:
    run: ../tools/expression_createsequencegrouping.cwl
    in:
      sequence_grouping_tsv: sequence_grouping_tsv
    out: [sequence_grouping_array]

  gatkv4_baserecalibrator:
    run: ../tools/gatk_baserecalibrator.cwl
    in:
      input_bam: picard_sortsam/output_sorted_bam
      knownsites: knownsites
      reference: indexed_reference_fasta
      sequence_interval: createsequencegrouping/sequence_grouping_array
    scatter: [sequence_interval]
    out: [output]

  gatk_gatherbqsrreports:
    run: ../tools/gatk_gatherbqsrreports.cwl
    in:
      input_brsq_reports: gatkv4_baserecalibrator/output
    out: [output]