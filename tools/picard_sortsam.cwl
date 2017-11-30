cwlVersion: v1.0
class: CommandLineTool
id: picard_sortsam
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.8.3'
  - class: ShellCommandRequirement
baseCommand: [java, '-Xmx4G', '-jar', /picard.jar]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      SortSam
      INPUT=$(inputs.input_bam.path)
      OUTPUT=$(inputs.input_bam.nameroot).sorted.bam
      SORT_ORDER="coordinate"
      CREATE_INDEX=true
      CREATE_MD5_FILE=true
      MAX_RECORDS_IN_RAM=300000
inputs:
  input_bam:
    type: File
outputs:
  output_sorted_bam:
    type: File
    outputBinding:
      glob: '*.sorted.bam'
    secondaryFiles: [^.bai, .md5]
