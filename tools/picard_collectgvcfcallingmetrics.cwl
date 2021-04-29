cwlVersion: v1.0
class: CommandLineTool
id: gatk_collectgvcfcallingmetrics
doc: |-
  This tool collects summary and per-sample metrics about variant calls in a VCF file.
  The following programs are run in this tool:
    - picard CollectVariantCallingMetrics
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 3000
    coresMin: 16
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R'
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
  input_vcf: { type: File, secondaryFiles: [.tbi], doc: "Input VCF file" }
  reference_dict: { type: File, doc: "Reference dict index file" }
  final_gvcf_base_name: { type: string, doc: "String to use as the base filename for the output" }
  dbsnp_vcf: { type: File, secondaryFiles: [.idx], doc: "dbsnp VCF file" }
  wgs_evaluation_interval_list: { type: File, doc: "Target intervals to restrict analysis to" }
outputs:
  output: { type: 'File[]', outputBinding: { glob: '*_metrics' } }
