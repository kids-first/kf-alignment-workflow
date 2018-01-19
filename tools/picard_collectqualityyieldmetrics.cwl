cwlVersion: v1.0
class: CommandLineTool
id: picard_collectqualityyieldmetrics
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.8.3'
  - class: ResourceRequirement
    ramMin: 8000
baseCommand: [ java, -Xms2000m, -Xmx8000m, -jar, /picard.jar, CollectQualityYieldMetrics]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      INPUT=$(inputs.input_bam.path)
      OQ=true
      OUTPUT=$(inputs.input_bam.nameroot).unmapped.quality_yield_metrics
inputs:
  input_bam:
    type: File
outputs:
  - id: output
    type: File
    outputBinding:
      glob: '*_metrics'
