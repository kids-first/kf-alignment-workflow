cwlVersion: v1.0
class: Workflow
id: bwa_mem_wf
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
inputs:
  input_reads: File
  original_bam: File
  indexed_reference_fasta: File
  base_name: string

outputs:
  aligned_bams:
    type: File[]
    outputSource: bwa_mem_split/output

steps:
  bwa_input_prepare:
    run: ../latest-tools/tools/bwa_input_prepare.cwl
    in:
      original_bam: original_bam
      input_bam: input_reads
    out: [output, rg]

  expression_updatergsample:
    run: ../latest-tools/tools/expression_preparerg.cwl
    in:
      rg: bwa_input_prepare/rg
      sample: base_name
    out: [rg_str]

  bwa_mem_split:
    run: ./bwa_mem_split.cwl
    in:
      ref: indexed_reference_fasta
      reads: bwa_input_prepare/output
      rg: expression_updatergsample/rg_str
    scatter: [reads]
    out: [output]
