cwlVersion: v1.0
class: CommandLineTool
id: samtools_bam_to_cram
doc: |-
  This tool converts the input BAM into a CRAM.
  The following programs are run in this tool:
    - samtools view
    - samtools index
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 4000
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/samtools:1.8-dev'
baseCommand: [samtools, view]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      -C -T $(inputs.reference.path) -o $(inputs.input_bam.nameroot).cram $(inputs.input_bam.path)
      && samtools index $(inputs.input_bam.nameroot).cram
inputs:
  reference: {type: File, secondaryFiles: [.fai], doc: "Reference fasta with associated fai index"}
  input_bam: {type: File, secondaryFiles: [^.bai], doc: "Input bam file"}
outputs:
  output: { type: File, outputBinding: { glob: '*.cram' }, secondaryFiles: [.crai] }
