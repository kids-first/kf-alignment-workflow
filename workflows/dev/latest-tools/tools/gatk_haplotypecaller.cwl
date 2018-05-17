cwlVersion: v1.0
class: CommandLineTool
id: gatk_haplotypecaller
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 8000
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.0.3.0'
baseCommand: [/gatk]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      --java-options "-Xms2000m"
      PrintReads
      -I $(inputs.input_bam.path)
      --interval-padding 500
      -L $(inputs.interval_list.path)
      -O local.sharded.bam && /gatk
      --java-options "-Xms8000m
      -XX:GCTimeLimit=50
      -XX:GCHeapFreeLimit=10"
      HaplotypeCaller
      -R $(inputs.reference.path)
      -O $(inputs.input_bam.nameroot).vcf.gz
      -I local.sharded.bam
      -L $(inputs.interval_list.path)
      -ERC GVCF
      --max-alternate-alleles 3
      -contamination $(inputs.contamination)
      --read-filter OverclippedReadFilter
inputs:
  reference: {type: File, secondaryFiles: [^.dict, .fai]}
  input_bam: {type: File, secondaryFiles: [^.bai]}
  interval_list: File
  contamination: float
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles: [.tbi]
