cwlVersion: v1.0
class: Workflow
id: kfdrc_process_pe_readslist2 
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
    secondaryFiles: ['.64.amb', '.64.ann', '.64.bwt', '.64.pac', '.64.sa', '^.dict', '.fai']
  min_alignment_score: int?
outputs:
  unsorted_bams: 
    type:
      type: array
      items:
        type: array
        items: File 
    outputSource: process_pe_set/unsorted_bams 

steps:
  process_pe_set:
    run: kfdrc_process_pe_set.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      input_pe_reads: input_pe_reads_list
      input_pe_mates: input_pe_mates_list
      input_pe_rgs: input_pe_rgs_list
      min_alignment_score: min_alignment_score
    scatter: [input_pe_reads, input_pe_mates, input_pe_rgs]
    scatterMethod: dotproduct
    out: [unsorted_bams]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
