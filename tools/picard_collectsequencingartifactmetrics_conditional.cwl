cwlVersion: v1.0
class: CommandLineTool
id: picard_collectsequencingartifactmetrics_conditional
doc: |-
  This tool collects sequencing artifact metrics on an input WGS/WXS bam.
  The following programs are run in this tool:
    - picard CollectSequencingArtifactMetrics
  This tool is also made to be used conditionally with the conditional_run parameter.
  Simply pass an empty array to conditional_run and scatter on the input to skip.
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 12000
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R'
baseCommand: [ java, -Xms5000m, -jar, /picard.jar, CollectSequencingArtifactMetrics]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      INPUT=$(inputs.input_bam.path)
      REFERENCE_SEQUENCE=$(inputs.reference.path)
      OUTPUT=$(inputs.input_bam.nameroot).artifact_metrics

inputs:
  input_bam: { type: File, secondaryFiles: [^.bai], doc: "Input bam file"}
  reference: { type: File, secondaryFiles: [.fai], doc: "Reference fasta with dict and fai indexes" }
  conditional_run: { type: int, doc: "Placeholder variable to allow conditional running" } 
outputs:
  bait_bias_detail_metrics: { type: File, outputBinding: { glob: '*.bait_bias_detail_metrics' } }
  bait_bias_summary_metrics: { type: File, outputBinding: { glob: '*.bait_bias_summary_metrics' } }
  error_summary_metrics: { type: File, outputBinding: { glob: '*.error_summary_metrics' } }
  pre_adapter_detail_metrics: { type: File, outputBinding: { glob: '*.pre_adapter_detail_metrics' } }
  pre_adapter_summary_metrics: { type: File, outputBinding: { glob: '*.pre_adapter_summary_metrics' } }
