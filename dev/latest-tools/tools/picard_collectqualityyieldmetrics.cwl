cwlVersion: v1.0
class: CommandLineTool
id: picard_collectqualityyieldmetrics
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.18.2-dev'
  - class: ResourceRequirement
    ramMin: 8000
baseCommand: [ java, -Xms2000m, -jar, /picard.jar, CollectQualityYieldMetrics]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      INPUT=$(inputs.input_bam.path)
      OQ=true
      OUTPUT=$(inputs.output_basename).$(inputs.input_bam.nameroot).unmapped.quality_yield_metrics
inputs:
  input_bam: File
  output_basename: string
outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.output_basename).$(inputs.input_bam.nameroot).unmapped.quality_yield_metrics
