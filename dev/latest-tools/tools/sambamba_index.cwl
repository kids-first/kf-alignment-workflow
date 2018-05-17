cwlVersion: v1.0
class: CommandLineTool
id: sambamba_index
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    coresMin: 36
  - class: DockerRequirement
    dockerPull: 'kfdrc/sambamba:v0.6.7-dev'
  - class: InitialWorkDirRequirement
    listing: []
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 7
    shellQuote: false
    valueFrom: >-
      mv $(inputs.bam.path) . && sambamba index -t 36
      $(inputs.bam.basename) $(inputs.bam.nameroot).bai
inputs:
  bam: File
outputs:
  indexed_bam:
    type: File
    outputBinding:
      glob: '*.bam'
    secondaryFiles: [^.bai]
