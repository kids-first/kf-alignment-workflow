cwlVersion: v1.0
class: CommandLineTool
id: gatk_collectgvcfcallingmetrics
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.8.3'
baseCommand: [java, '-Xms2000m', '-jar', /picard.jar, CollectVariantCallingMetrics]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      INPUT=$(inputs.input_vcf.path)
      OUTPUT=$(inputs.final_gvcf_base_name)
      DBSNP=$(inputs.dbsnp_vcf.path)
      SEQUENCE_DICTIONARY=$(inputs.reference_dict.path)
      TARGET_INTERVALS=$(inputs.wgs_evaluation_interval_list.path)
      GVCF_INPUT=true
inputs:
  input_vcf:
    type: File
    secondaryFiles: [.tbi]
  reference_dict:
    type: File
  final_gvcf_base_name:
    type: string
  dbsnp_vcf:
    type: File
    secondaryFiles: [.idx]
  wgs_evaluation_interval_list:
    type: File
outputs:
  output:
    type: File[]
    outputBinding:
      glob: '*_metrics'
