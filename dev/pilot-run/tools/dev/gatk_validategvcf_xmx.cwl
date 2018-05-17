cwlVersion: v1.0
class: CommandLineTool
id: gatk_validategvcf
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:3.6-0-g89b7209'
  - class: ResourceRequirement
    ramMin: 4000
baseCommand: [/usr/bin/java, -Xms2000m, -Xmx30000m, -jar, /GenomeAnalysisTK.jar]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      -T ValidateVariants
      -V $(inputs.input_vcf.path)
      -R $(inputs.reference.path)
      -L $(inputs.wgs_calling_interval_list.path)
      -gvcf
      --validationTypeToExclude ALLELES
      --dbsnp $(inputs.dbsnp_vcf.path)
inputs:
  input_vcf:
    type: File
    secondaryFiles: .tbi
  reference:
    type: File
    secondaryFiles: [^.dict, .fai]
  wgs_calling_interval_list:
    type: File
  dbsnp_vcf:
    type: File
    secondaryFiles: .idx
outputs: []
