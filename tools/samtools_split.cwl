class: CommandLineTool
cwlVersion: v1.0
id: samtools_split
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'images.sbgenomics.com/bogdang/samtools:1.7-11-g041220d'
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      samtools split -f '%!.bam' -@ 36 --reference $(inputs.reference.path)
      $(inputs.input_bam.path)
inputs:
  input_bam: File
  reference: File
outputs:
  bam_files:
    type: File[]
    outputBinding:
      glob: '*.bam'
