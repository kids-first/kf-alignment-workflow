cwlVersion: v1.0
class: Workflow
id: paired_single_sample_wf
requirements:
  - class: ScatterFeatureRequirement

inputs:
  input_bam: File
  indexed_reference_fasta: File
  base_file_name: string

outputs:
  duplicates_marked_bam:
    type: File
    outputSource: picard_markduplicates/output_markduplicates_bam
  sorted_bam:
    type: File
    outputSource: picard_sortsam/output_sorted_bam

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