cwlVersion: v1.0
class: CommandLineTool
id: picard_collectunsortedreadgroupbamqualitymetrics
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R'
  - class: ResourceRequirement
    ramMin: 8000
baseCommand: [ java, -Xms5000m, -jar, /picard.jar, CollectMultipleMetrics]
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
  input_bam: File
outputs:
  output:
    type: File[]
    outputBinding:
      glob: $(inputs.input_bam.nameroot).*
