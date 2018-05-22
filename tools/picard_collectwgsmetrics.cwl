cwlVersion: v1.0
class: CommandLineTool
id: picard_collectwgsmetrics
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 8000
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.18.2-dev'
baseCommand: [ java, -Xms2000m, -jar, /picard.jar, CollectWgsMetrics]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      INPUT=$(inputs.input_bam.path)
      VALIDATION_STRINGENCY=SILENT
      REFERENCE_SEQUENCE=$(inputs.reference.path)
      INCLUDE_BQ_HISTOGRAM=true
      INTERVALS=$(inputs.intervals.path)
      OUTPUT=$(inputs.input_bam.nameroot).wgs_metrics
      USE_FAST_ALGORITHM=true
      READ_LENGTH=250
inputs:
  input_bam: {type: File, secondaryFiles: [^.bai]}
  reference: {type: File, secondaryFiles: [.fai]}
  intervals: File
outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input_bam.nameroot).wgs_metrics
