cwlVersion: v1.0
class: CommandLineTool
id: picard_collecthsmetrics_conditional
doc: |-
  This tool collects hs metrics on an input WXS bam.
  The following programs are run in this tool:
    - picard CollectHsMetrics
  This tool is also made to be used conditionally with the conditional_run parameter.
  Simply pass an empty array to conditional_run and scatter on the input to skip.
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
      BAIT_INTERVALS=$(inputs.bait_intervals.path)
      TARGET_INTERVALS=$(inputs.target_intervals.path)
      OUTPUT=$(inputs.input_bam.nameroot).hs_metrics

inputs:
  input_bam: { type: File, secondaryFiles: [^.bai], doc: "Input bam file"}
  reference: { type: File, secondaryFiles: [.fai], doc: "Reference fasta with dict and fai indexes" }
  bait_intervals: { type: File, doc: "An interval list file that contains the locations of the baits used" }
  target_intervals: { type: File, doc: "An interval list file that contains the locations of the targets" }
  conditional_run: { type: int, doc: "Placeholder variable to allow conditional running" } 
outputs:
  output: { type: File, outputBinding: { glob: '*.hs_metrics' } }
