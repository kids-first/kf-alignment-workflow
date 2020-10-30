cwlVersion: v1.0
class: CommandLineTool
id: picard_collecthsmetrics
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 8000
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.2-dev'
baseCommand: [ java, -Xms2000m, -jar, /picard.jar, CollectHsMetrics]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      INPUT=$(inputs.input_bam.path)
      REFERENCE_SEQUENCE=$(inputs.reference.path)
      BAIT_INTERVALS=$(inputs.intervals.path)
      TARGET_INTERVALS=$(inputs.intervals.path)
      OUTPUT=$(inputs.input_bam.nameroot).hs_metrics

inputs:
  input_bam: {type: File, secondaryFiles: [^.bai]}
  reference: {type: File, secondaryFiles: [.fai]}
  intervals: File
outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input_bam.nameroot).hs_metrics
