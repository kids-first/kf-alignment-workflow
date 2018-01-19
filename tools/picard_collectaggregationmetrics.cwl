cwlVersion: v1.0
class: CommandLineTool
id: picard_collectaggregationmetrics
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard-r:picard2.8.3-r3.3.3'
  - class: ResourceRequirement
    ramMin: 8000
baseCommand: [ java, -Xms5000m, -Xmx8000m, -jar, /picard.jar, CollectMultipleMetrics]
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
  input_bam:
    type: File
    secondaryFiles: [^.bai]
  reference:
    type: File
    secondaryFiles: [^.dict, .fai]
outputs:
  output1:
    type: File[]
    outputBinding:
      glob: '*_metrics'
  output2:
    type: File[]
    outputBinding:
      glob: '*_pdf'
