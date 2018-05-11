cwlVersion: v1.0
class: CommandLineTool
id: bwa_mem
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.18.2-dev'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 8000
baseCommand: [java, -Xms5000m, -Xmx8000m, -jar, /picard.jar]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      SamToFastq
      INPUT=$(inputs.input_bam.path)
      FASTQ=$(inputs.input_bam.nameroot).fastq
      INTERLEAVE=true
      NON_PF=true
inputs:
  input_bam: File
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.fastq'
