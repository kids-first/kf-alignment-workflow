cwlVersion: v1.0
class: CommandLineTool
id: picard_collectgcbiasmetrics
doc: |-
  This tool collects gc bias metrics on an input WGS/WXS bam.
  The following programs are run in this tool:
    - picard CollectGcBiasMetrics
  This tool is also made to be used conditionally with the conditional_run parameter.
  Simply pass an empty array to conditional_run and scatter on the input to skip.
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 12000
  - class: DockerRequirement
    dockerPull: '684194535433.dkr.ecr.us-east-1.amazonaws.com/d3b-healthomics:picard'
baseCommand: [ java, -Xms5000m, -jar, /picard.jar, CollectGcBiasMetrics]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      INPUT=$(inputs.input_bam.path)
      REFERENCE_SEQUENCE=$(inputs.reference.path)
      OUTPUT=$(inputs.input_bam.nameroot).gc_bias_metrics.txt
      SUMMARY_OUTPUT=$(inputs.input_bam.nameroot).gc_bias_summary_metrics.txt
      CHART_OUTPUT=$(inputs.input_bam.nameroot).gc_bias_metrics.pdf
      METRIC_ACCUMULATION_LEVEL="null"
      METRIC_ACCUMULATION_LEVEL="SAMPLE"
      METRIC_ACCUMULATION_LEVEL="LIBRARY"

inputs:
  input_bam: { type: File, secondaryFiles: [^.bai], doc: "Input bam file"}
  reference: { type: File, secondaryFiles: [.fai], doc: "Reference fasta with dict and fai indexes" }
  conditional_run: { type: int, doc: "Placeholder variable to allow conditional running" } 
outputs:
  detail: { type: File, outputBinding: { glob: '*.gc_bias_metrics.txt' } }
  summary: { type: File, outputBinding: { glob: '*.summary_metrics.txt' } }
  chart: { type: File, outputBinding: { glob: '*.gc_bias_metrics.pdf' } }
