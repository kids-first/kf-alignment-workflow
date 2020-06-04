cwlVersion: v1.0
class: Workflow
id: kfdrc_process_se_set
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
inputs:
  input_se_reads: File
  input_se_rgs: string
  indexed_reference_fasta:
    type: File
    secondaryFiles: ['.64.amb', '.64.ann', '.64.bwt', '.64.pac', '.64.sa', '.64.alt', '^.dict']
  min_alignment_score: int?
outputs:
  unsorted_bams: 
    type: File[]
    outputSource: bwa_mem_split_se_reads/output

steps:
  zcat_split_reads:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.9xlarge
    run: ../tools/fastq_chomp.cwl
    in:
      input_fastq: input_se_reads
    out: [output]
 
  bwa_mem_split_se_reads:
    run: ../tools/bwa_mem_naive.cwl
    in:
      ref: indexed_reference_fasta
      reads: zcat_split_reads/output
      rg: input_se_rgs
      min_alignment_score: min_alignment_score
    scatter: reads
    out: [output] #+0 Nesting File[]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
