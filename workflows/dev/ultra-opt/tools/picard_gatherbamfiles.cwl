cwlVersion: v1.0
class: CommandLineTool
id: picard_gatherbamfiles
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.18.2-dev'
  - class: ResourceRequirement
    ramMin: 8000
baseCommand: [ java, -Xms2000m, -jar, /picard.jar, GatherBamFiles]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      OUTPUT=$(inputs.output_bam_basename).bam
      CREATE_INDEX=true
      CREATE_MD5_FILE=true
inputs:
  input_bam:
    type:
      type: array
      items: File
      inputBinding:
        prefix: INPUT=
        separate: false
    secondaryFiles: [^.bai]
  output_bam_basename: string
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.bam'
    secondaryFiles: [^.bai, .md5]
