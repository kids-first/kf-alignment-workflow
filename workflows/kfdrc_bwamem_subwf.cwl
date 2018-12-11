cwlVersion: v1.0
class: Workflow
id: bwa_mem_wf
label: BWA-MEM
doc: Run bwa-mem v0.7.17 and create custom RG info on temporarily split input reads
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
inputs:
  input_reads: File
  reference_fasta: File
  bwa_index_tar: File
  sample_name: string

outputs:
  aligned_bams:
    type: File[]
    outputSource: bwa_mem_split/output

steps:
  bwa_input_prepare:
    run: ../tools/bwa_input_prepare.cwl
    in:
      input_bam: input_reads
      reference_fasta: reference_fasta
    out: [output, rg]

  expression_updatergsample:
    run: ../tools/expression_preparerg.cwl
    in:
      rg: bwa_input_prepare/rg
      sample: sample_name
    out: [rg_str]

  bwa_mem_split:
    run: ../tools/bwa_mem_split.cwl
    in:
      ref: reference_fasta
      secondaryFiles: [.64.amb, .64.ann, .64.bwt, .64.pac,
                       .64.sa, .64.alt, ^.dict, .amb, .ann, .bwt, .pac, .sa]
      reads: bwa_input_prepare/output
      bwa_index_tar: bwa_index_tar
      rg: expression_updatergsample/rg_str
    scatter: [reads]
    out: [output]
