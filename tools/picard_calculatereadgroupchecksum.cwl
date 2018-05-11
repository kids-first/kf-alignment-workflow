cwlVersion: v1.0
class: CommandLineTool
id: picard_calculatereadgroupchecksum
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.18.2-dev'
  - class: ResourceRequirement
    ramMin: 4000
baseCommand: [ java, -Xms2000m, -jar, /picard.jar, CalculateReadGroupChecksum]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      INPUT=$(inputs.input_bam.path)
      OUTPUT=$(inputs.input_bam.nameroot).bam.read_group_md5
inputs:
  input_bam:
    type: File
    secondaryFiles:
      - ^.bai
outputs:
  - id: output
    type: File
    outputBinding:
      glob: '*.md5'
