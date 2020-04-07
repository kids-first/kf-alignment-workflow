cwlVersion: v1.0
class: CommandLineTool
id: picard_collecthsmetrics
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 8000
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.18.2-dev'
baseCommand: [ java, -Xms2000m, -jar, /picard.jar, CollectHsMetrics]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      INPUT=$(inputs.input_bam.path)
      REFERENCE_SEQUENCE=$(inputs.reference.path)
      BAIT_INTERVALS=$(inputs.bait_intervals.path)
      TARGET_INTERVALS=$(inputs.target_intervals.path)
      OUTPUT=$(inputs.input_bam.nameroot).hs_metrics

inputs:
  input_bam: {type: File, secondaryFiles: [^.bai]}
  reference: {type: File, secondaryFiles: [.fai]}
  bait_intervals: File
  target_intervals: File
  conditional_run: int
outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input_bam.nameroot).hs_metrics
