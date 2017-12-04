cwlVersion: v1.0
class: CommandLineTool
id: picard_collectunsortedreadgroupbamqualitymetrics
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.8.3'
baseCommand: [ java, '-Xms5000m', '-jar', /picard.jar, CollectMultipleMetrics]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      INPUT=$(inputs.input_bam.path)
      OUTPUT=$(inputs.input_bam.nameroot)
      ASSUME_SORTED=true
      PROGRAM="null"
      PROGRAM="CollectBaseDistributionByCycle"
      PROGRAM="CollectInsertSizeMetrics" 
      PROGRAM="MeanQualityByCycle" 
      PROGRAM="QualityScoreDistribution" 
      METRIC_ACCUMULATION_LEVEL="null" 
      METRIC_ACCUMULATION_LEVEL="ALL_READS"
inputs:
  input_bam:
    type: File
outputs:
  output1:
    type: File[]
    outputBinding:
      glob: '*_metrics'
  output2:
    type: File[]
    outputBinding:
      glob: '*.pdf'
