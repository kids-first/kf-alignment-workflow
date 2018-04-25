cwlVersion: v1.0
class: CommandLineTool
id: gatk_validategvcf
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.0.3.0'
  - class: ResourceRequirement
    ramMin: 30000
baseCommand: [/gatk]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      --java-options "-Xms2000m"
      ValidateVariants
      -V $(inputs.input_vcf.path)
      -R $(inputs.reference.path)
      -L $(inputs.wgs_calling_interval_list.path)
      -gvcf
      --validation-type-to-exclude ALLELES
      --dbsnp $(inputs.dbsnp_vcf.path)
inputs:
  input_vcf: {type: File, secondaryFiles: .tbi}
  reference: {type: File, secondaryFiles: [^.dict, .fai]}
  wgs_calling_interval_list: File
  dbsnp_vcf: {type: File, secondaryFiles: .idx}
outputs: []
