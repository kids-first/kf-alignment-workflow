cwlVersion: v1.0
class: CommandLineTool
id: picard_sortsam
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.18.2-dev'
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 8000
baseCommand: [java, -Xms4000m, -jar, /picard.jar]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      SortSam
      INPUT=$(inputs.input_bam.path)
      OUTPUT=$(inputs.base_file_name).aligned.duplicates_marked.sorted.bam
      SORT_ORDER="coordinate"
      CREATE_INDEX=true
      CREATE_MD5_FILE=true
      MAX_RECORDS_IN_RAM=300000
inputs:
  input_bam: File
  base_file_name: string
outputs:
  output_sorted_bam:
    type: File
    outputBinding:
      glob: '*.sorted.bam'
    secondaryFiles: [^.bai, .md5]
