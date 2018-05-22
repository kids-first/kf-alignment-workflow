cwlVersion: v1.0
class: CommandLineTool
id: gatk_haplotypecaller
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 10000
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.beta.1-3.5'
baseCommand: [/gatk-launch, --javaOptions, -Xms2000m]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      PrintReads
      -I $(inputs.input_bam.path)
      --interval_padding 500
      -L $(inputs.interval_list.path)
      -O local.sharded.bam && java -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -Xms8000m
      -jar /GenomeAnalysisTK.jar
      -T HaplotypeCaller
      -R $(inputs.reference.path)
      -o $(inputs.input_bam.nameroot).vcf.gz
      -I local.sharded.bam
      -L $(inputs.interval_list.path)
      -ERC GVCF
      --max_alternate_alleles 3
      -variant_index_parameter 128000
      -variant_index_type LINEAR
      -contamination $(inputs.contamination)
      --read_filter OverclippedRead
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
