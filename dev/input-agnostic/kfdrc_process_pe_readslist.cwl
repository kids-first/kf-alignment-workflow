cwlVersion: v1.0
class: Workflow
id: kfdrc_process_readslist 
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
inputs:
  input_pe_reads_list: File[]
  input_pe_mates_list: File[]
  input_pe_rgs_list: string[]
  conditional_run: int
  indexed_reference_fasta:
    type: File
    secondaryFiles: ['.64.amb', '.64.ann', '.64.bwt', '.64.pac', '.64.sa', '.64.alt', '^.dict', '.amb', '.ann', '.bwt', '.pac', '.sa']
outputs:
  unsorted_bams: 
    type: File[]
    outputSource: bwa_mem_naive_pe_reads/output

steps:
  bwa_mem_naive_pe_reads:
    run: ../tools/bwa_mem_naive.cwl
    in:
      ref: indexed_reference_fasta
      reads: input_pe_reads_list
      mates: input_pe_mates_list 
      rg: input_pe_rgs_list 
    scatter: [reads, mates, rg]
    scatterMethod: dotproduct
    out: [output] #+0 Nesting File[]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
