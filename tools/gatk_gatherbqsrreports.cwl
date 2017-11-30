cwlVersion: v1.0
class: CommandLineTool
id: gatk4_applybqsr
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.beta.1'
baseCommand: [/gatk-launch, --javaOptions, "-Xms3000m"]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      GatherBQSRReports
      -O bqsr.combined.report
inputs:
  bqsr:
    type:
      type: array
      items: File
      inputBinding:
        prefix: '-I'
    inputBinding: 
      position: 1
outputs:
  output_report:
    type: File
    outputBinding:
      glob: 'bqsr.combined.report'
