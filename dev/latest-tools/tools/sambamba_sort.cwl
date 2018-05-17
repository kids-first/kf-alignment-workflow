cwlVersion: v1.0
class: CommandLineTool
id: sambamba_sort
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1024
    coresMin: 36
  - class: DockerRequirement
    dockerPull: 'kfdrc/sambamba:v0.6.7-dev'
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      sambamba
      sort $(inputs.bam.path) -t 36
      -o $(inputs.base_file_name).$(inputs.suffix).bam

      mv $(inputs.base_file_name).$(inputs.suffix).bam.bai $(inputs.base_file_name).$(inputs.suffix).bai
inputs:
  bam: File
  base_file_name: string
  suffix:
    type: string
    default: aligned.duplicates_marked.sorted
outputs:
  sorted_bam:
    type: File
    outputBinding:
      glob: '*.bam'
    secondaryFiles: [^.bai]
    format: BAM
