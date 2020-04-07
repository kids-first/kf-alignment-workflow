cwlVersion: v1.0
class: CommandLineTool
id: picard_collectaggregationmetrics
doc: |-
  This tool collects multiple metrics on an input bam.
  The following programs are run in this tool:
    - picard CollectMultipleMetrics
  This tool is also made to be used conditionally with the conditional_run parameter.
  Simply pass an empty array to conditional_run and scatter on the input to skip. 
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard-r:latest-dev'
  - class: ResourceRequirement
    ramMin: 12000
baseCommand: [ java, -Xms5000m, -jar, /picard.jar, CollectMultipleMetrics]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      INPUT=$(inputs.input_bam.path)
      REFERENCE_SEQUENCE=$(inputs.reference.path)
      OUTPUT=$(inputs.input_bam.nameroot)
      ASSUME_SORTED=true
      PROGRAM="null"
      PROGRAM="CollectAlignmentSummaryMetrics" 
      PROGRAM="CollectInsertSizeMetrics" 
      PROGRAM="CollectSequencingArtifactMetrics" 
      PROGRAM="CollectGcBiasMetrics" 
      PROGRAM="QualityScoreDistribution" 
      METRIC_ACCUMULATION_LEVEL="null" 
      METRIC_ACCUMULATION_LEVEL="SAMPLE" 
      METRIC_ACCUMULATION_LEVEL="LIBRARY"
inputs:
  input_bam: { type: File, secondaryFiles: [^.bai], doc: "Input bam file" }
  reference: { type: File, secondaryFiles: [^.dict, .fai], doc: "Reference fasta with dict and fai indexes" }
  conditional_run: { type: int, doc: "Placeholder variable to allow conditional running" }
outputs:
  output: { type: 'File[]', outputBinding: { glob: $(inputs.input_bam.nameroot).* } }
