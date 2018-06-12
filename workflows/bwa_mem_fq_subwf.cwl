cwlVersion: v1.0
class: Workflow
id: bwa_mem_fq_wf
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
inputs:
  files_R1: File[]
  files_R2: File[]
  ref: File
  rgs: string[]

outputs:
  aligned_bams:
    type: File[]
    outputSource: bwa_mem_split/output

steps:
  bwa_mem_split:
    run: ../tools/bwa_mem_fq.cwl
    in:
      file_R1: files_R1
      file_R2: files_R2
      rg: rgs
      ref: ref
    scatter: [file_R1, file_R2, rg]
    scatterMethod: dotproduct
    out: [output] 
