cwlVersion: v1.0
class: CommandLineTool
id: picard_collectaggregationmetrics
label: Picard multi-metrics
doc: 'Collect metrics using picard tools: CollectAlignmentSummaryMetrics, CollectInsertSizeMetrics, CollectSequencingArtifactMetrics, CollectGcBiasMetrics, QualityScoreDistribution'
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
  input_bam: File
  reference_fasta: File
  reference_dict: File
  reference_fai: File
outputs:
  output:
    type: File[]
    outputBinding:
      glob: $(inputs.input_bam.nameroot).*
