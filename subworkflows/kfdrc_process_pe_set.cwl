cwlVersion: v1.0
class: Workflow
id: kfdrc_process_pe_set
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
inputs:
  input_pe_reads: File
  input_pe_mates: File
  input_pe_rgs: string
  indexed_reference_fasta:
    type: File
    secondaryFiles: ['.64.amb', '.64.ann', '.64.bwt', '.64.pac', '.64.sa', '.64.alt', '^.dict'] 
  min_alignment_score: int?
outputs:
  unsorted_bams: 
    type: File[]
    outputSource: bwa_mem_split_pe_reads/output

steps:
  zcat_split_reads:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.9xlarge
    run: ../tools/fastq_chomp.cwl
    in:
      input_fastq: input_pe_reads
    out: [output]

  zcat_split_mates:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.9xlarge
    run: ../tools/fastq_chomp.cwl
    in:
      input_fastq: input_pe_mates
    out: [output]
 
  bwa_mem_split_pe_reads:
    run: ../tools/bwa_mem_naive.cwl
    in:
      ref: indexed_reference_fasta
      reads: zcat_split_reads/output
      mates: zcat_split_mates/output
      rg: input_pe_rgs
      min_alignment_score: min_alignment_score
    scatter: [reads, mates]
    scatterMethod: dotproduct
    out: [output] #+0 Nesting File[]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
