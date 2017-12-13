cwlVersion: v1.0
class: CommandLineTool
id: gatk_validategvcf
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.beta.1'
baseCommand: [/gatk-launch, ValidateVariants]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      --javaOptions "-Xms3000m"
      -V $(inputs.input_vcf.path)
      -R $(inputs.reference.path)
      -L $(inputs.wgs_calling_interval_list.path)
      -gvcf
      --validationTypeToExclude ALLELES
      --dbsnp $(inputs.dbsnp_vcf.path)
inputs:
  input_vcf:
    type: File
  reference:
    type: File
    secondaryFiles: [^.dict, .fai]
  wgs_calling_interval_list:
    type: File
  dbsnp_vcf:
    type: File
outputs: []
