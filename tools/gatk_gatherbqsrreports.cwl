cwlVersion: v1.0
class: CommandLineTool
id: gatk_gatherbqsrreports
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.0.3.0'
  - class: ResourceRequirement
    ramMin: 8000
baseCommand: [/gatk, GatherBQSRReports]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      --java-options "-Xms3000m"
      -O $(inputs.output_basename).GatherBqsrReports.recal_data.csv
inputs:
  input_brsq_reports:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -I
        separate: true
  output_basename: string
outputs:
  - id: output
    type: File
    outputBinding:
      glob: '*.csv'
