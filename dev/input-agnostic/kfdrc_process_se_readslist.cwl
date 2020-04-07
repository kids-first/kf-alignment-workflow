cwlVersion: v1.0
class: Workflow
id: bwa_mem_naive_wf
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
inputs:
  input_se_reads_list: File[]
  input_se_rgs_list: string[]
  indexed_reference_fasta:
    type: File
    secondaryFiles: ['.64.amb', '.64.ann', '.64.bwt', '.64.pac', '.64.sa', '.64.alt', '^.dict', '.amb', '.ann', '.bwt', '.pac', '.sa']
  conditional_run: int
outputs:
  unsorted_bams:
    type: File[]
    outputSource: bwa_mem_naive_se_reads/output 

steps:
  bwa_mem_naive_se_reads:
    run: ../tools/bwa_mem_naive.cwl
    in:
      ref: indexed_reference_fasta
      reads: input_se_reads_list 
      rg: input_se_rgs_list 
    scatter: [reads, rg]
    scatterMethod: dotproduct
    out: [output] #+0 Nesting File[]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
