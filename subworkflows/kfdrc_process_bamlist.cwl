cwlVersion: v1.0
class: Workflow
id: kfdrc_process_bamlist 
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
inputs:
  input_bam_list: File[]
  indexed_reference_fasta:
    type: File
    secondaryFiles: ['.64.amb', '.64.ann', '.64.bwt', '.64.pac', '.64.sa', '^.dict', '.fai']
  sample_name: string
  conditional_run: int
  min_alignment_score: int?
outputs:
  unsorted_bams:
    type:
      type: array
      items:
        type: array
        items:
          type: array
          items: File
    outputSource: process_bams/unsorted_bams 

steps:
  process_bams:
    run: kfdrc_process_bam.cwl
    in:
      input_bam: input_bam_list 
      indexed_reference_fasta: indexed_reference_fasta
      sample_name: sample_name
      min_alignment_score: min_alignment_score
    scatter: input_bam
    out: [unsorted_bams] #+2 Nesting File[][][]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
