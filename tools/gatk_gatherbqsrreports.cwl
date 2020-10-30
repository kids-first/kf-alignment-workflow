cwlVersion: v1.0
class: CommandLineTool
id: gatk_gatherbqsrreports
doc: |-
  This tool gathers the BQSR reports.
  The following programs are run in this tool:
    - GATK GatherBQSRReports
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.3.0'
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
    doc: "List of bqsr report files"
  output_basename: { type: string, doc: "String to be used as the basename for the gathered bqsr report file" }
outputs:
  output: { type: File, outputBinding: { glob: '*.csv' } }
