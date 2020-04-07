cwlVersion: v1.0
class: CommandLineTool
id: picard_collectwgsmetrics
doc: |-
  This tool collects wgs metrics on an input WGS bam.
  The following programs are run in this tool:
    - picard CollectWgsMetrics
  This tool is also made to be used conditionally with the conditional_run parameter.
  Simply pass an empty array to conditional_run and scatter on the input to skip.
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
  input_bam: { type: File, secondaryFiles: [^.bai], doc: "Input bam file" }
  reference: { type: File, secondaryFiles: [.fai], doc: "Reference fasta and fai index" }
  intervals: { type: File, doc: "An interval list file that contains the positions to restrict the assessment" }
  conditional_run: { type: int, doc: "Placeholder variable to allow conditional running" }
outputs:
  output: { type: File, outputBinding: { glob: $(inputs.input_bam.nameroot).wgs_metrics } }
