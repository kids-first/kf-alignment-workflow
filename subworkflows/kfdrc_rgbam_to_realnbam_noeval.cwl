cwlVersion: v1.0
class: Workflow
id: kfdrc_rgbam_to_realnbam_noeval
requirements:
  - class: ScatterFeatureRequirement
inputs:
  input_rgbam: File
  indexed_reference_fasta:
    type: File
    secondaryFiles: ['.64.amb', '.64.ann', '.64.bwt', '.64.pac', '.64.sa', '.64.alt', '^.dict']
  sample_name: string
  min_alignment_score: int?
outputs:
  unsorted_bams:
    type: File[]
    outputSource: bwa_mem_naive_bam/output

steps:
  bamtofastq_chomp_noeval:
    run: ../tools/bamtofastq_chomp_noeval.cwl
    in:
      input_bam: input_rgbam
    out: [output, rg]

  expression_updatergsample:
    run: ../tools/expression_preparerg.cwl
    in:
      rg: bamtofastq_chomp_noeval/rg
      sample: sample_name
    out: [rg_str]

  bwa_mem_naive_bam:
    run: ../tools/bwa_mem_naive.cwl
    in:
      ref: indexed_reference_fasta
      reads: bamtofastq_chomp_noeval/output
      interleaved:
        default: true
      rg: expression_updatergsample/rg_str 
      min_alignment_score: min_alignment_score
    scatter: [reads]
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
