cwlVersion: v1.0
class: CommandLineTool
id: picard_collectinsertsizemetrics_conditional
doc: |-
  This tool collects insert size metrics on an input WGS/WXS bam.
  The following programs are run in this tool:
    - picard CollectInsertSizeMetrics
  This tool is also made to be used conditionally with the conditional_run parameter.
  Simply pass an empty array to conditional_run and scatter on the input to skip.
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 12000
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard-r:latest-dev'
baseCommand: [ java, -Xms5000m, -jar, /picard.jar, CollectInsertSizeMetrics]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      INPUT=$(inputs.input_bam.path)
      REFERENCE_SEQUENCE=$(inputs.reference.path)
      OUTPUT=$(inputs.input_bam.nameroot).insert_size_metrics
      HISTOGRAM_FILE=$(inputs.input_bam.nameroot).insert_size_Histogram.pdf
      METRIC_ACCUMULATION_LEVEL="null"
      METRIC_ACCUMULATION_LEVEL="SAMPLE"
      METRIC_ACCUMULATION_LEVEL="LIBRARY"

inputs:
  input_bam: { type: File, secondaryFiles: [^.bai], doc: "Input bam file"}
  reference: { type: File, secondaryFiles: [.fai], doc: "Reference fasta with dict and fai indexes" }
  conditional_run: { type: int, doc: "Placeholder variable to allow conditional running" } 
outputs:
  metrics: { type: File, outputBinding: { glob: '*.insert_size_metrics' } }
  plot: { type: File, outputBinding: { glob: '*.insert_size_Histogram.pdf' } }
