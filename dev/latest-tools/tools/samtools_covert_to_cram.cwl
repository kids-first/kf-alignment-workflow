cwlVersion: v1.0
class: CommandLineTool
id: samtools_convert_to_cram
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 4000
  - class: DockerRequirement
    dockerPull: 'kfdrc/samtools:1.8-dev'
baseCommand: [samtools, view]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      -C -T $(inputs.reference.path) -o $(inputs.input_bam.nameroot).cram $(inputs.input_bam.path)
      && samtools index $(inputs.input_bam.nameroot).cram
inputs:
  reference: {type: File, secondaryFiles: [.fai]}
  input_bam: {type: File, secondaryFiles: [^.bai]}
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.cram'
    secondaryFiles: [.crai]
