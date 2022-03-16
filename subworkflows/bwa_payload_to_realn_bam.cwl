cwlVersion: v1.2
class: Workflow
id: rgbam_to_bwa_payload
requirements:
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
inputs:
  sentieon_license: string
  indexed_reference_fasta:
    type: File
    secondaryFiles: [{ pattern: '.fai', required: true }, { pattern: '^.dict', required: true }, { pattern: '.64.amb', required: true }, { pattern: '.64.ann', required: true }, { pattern: '.64.bwt', required: true }, { pattern: '.64.pac', required: true }, { pattern: '.64.sa', required: true }, { pattern: '.64.alt', required: false }]
    sbg:fileTypes: FA, FASTA
  min_alignment_score: int
  bwa_payload:
    type:
      type: record
      fields:
        reads_file:
          type: File
        mates_file:
          type: File?
        rg_str:
          type: string
        interleaved:
          type: boolean
  cpu_per_job: { type: 'int?' }
  mem_per_job: { type: 'int?' }
outputs:
  realgn_bam: 
    type: File
    outputSource: sentieon_bwa_mem/output 

steps:
  sentieon_bwa_mem:
    run: ../tools/sentieon_bwa_sort.cwl
    in:
      sentieon_license: sentieon_license
      reference: indexed_reference_fasta
      reads_forward:
        source: bwa_payload
        valueFrom: $(self.reads_file)
      reads_mate:
        source: bwa_payload
        valueFrom: $(self.mates_file)
      rg:
        source: bwa_payload
        valueFrom: $(self.rg_str)
      interleaved:
        source: bwa_payload
        valueFrom: $(self.interleaved)
      min_alignment_score: min_alignment_score
      cpu_per_job: cpu_per_job
      mem_per_job: mem_per_job
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
