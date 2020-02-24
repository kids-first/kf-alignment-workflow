cwlVersion: v1.0
class: Workflow
id: bwa_mem_naive_wf
requirements:
  - class: ScatterFeatureRequirement
inputs:
  input_rgbam: File
  indexed_reference_fasta:
    type: File
    secondaryFiles: ['.64.amb', '.64.ann', '.64.bwt', '.64.pac', '.64.sa', '.64.alt', '^.dict', '.amb', '.ann', '.bwt', '.pac', '.sa']
  sample_name: string
outputs:
  unsorted_bams:
    type: File[]
    outputSource: bwa_mem_naive_bam/output

steps:
  bamtofastq_chomp:
    run: ../tools/bamtofastq_chomp.cwl
    in:
      input_bam: input_rgbam
    out: [output, rg]

  update_rg_sm:
    run: ../tools/update_rg_sm.cwl
    in:
      rg: bamtofastq_chomp/rg
      sample: sample_name
    out: [rg_str]

  bwa_mem_naive_bam:
    run: ../tools/bwa_mem_naive.cwl
    in:
      ref: indexed_reference_fasta
      reads: bamtofastq_chomp/output
      interleaved:
        default: true
      rg: update_rg_sm/rg_str
    scatter: [reads]
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
