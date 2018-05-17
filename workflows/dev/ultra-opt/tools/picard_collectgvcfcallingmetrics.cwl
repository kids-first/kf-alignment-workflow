cwlVersion: v1.0
class: CommandLineTool
id: gatk_collectgvcfcallingmetrics
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 3000
    coresMin: 16
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.18.2-dev'
baseCommand: [java, -Xms2000m, -jar, /picard.jar, CollectVariantCallingMetrics]
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
      THREAD_COUNT=16
inputs:
  input_vcf: {type: File, secondaryFiles: [.tbi]}
  reference_dict: File
  final_gvcf_base_name: string
  dbsnp_vcf: {type: File, secondaryFiles: [.idx]}
  wgs_evaluation_interval_list: File
outputs:
  output:
    type: File[]
    outputBinding:
      glob: '*_metrics'
