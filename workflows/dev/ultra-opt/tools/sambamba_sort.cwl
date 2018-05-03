cwlVersion: v1.0
class: CommandLineTool
id: sambamba_sort
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 15000
    coresMin: 36
  - class: DockerRequirement
    dockerPull: 'images.sbgenomics.com/bogdang/sambamba:0.6.3'
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      /opt/sambamba_0.6.3/sambamba_v0.6.3 sort
      -t 36 -m 10G
      -o $(inputs.base_file_name).$(inputs.suffix).bam
      $(inputs.bam.path)

      mv $(inputs.base_file_name).$(inputs.suffix).bam.bai $(inputs.base_file_name).$(inputs.suffix).bai

      rm $(inputs.bam.path)
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
