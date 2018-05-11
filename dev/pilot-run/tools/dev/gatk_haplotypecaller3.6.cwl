cwlVersion: v1.0
class: CommandLineTool
id: gatk_haplotypecaller
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 8000
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:3.6-0-g89b7209'
baseCommand: [/usr/bin/java, -Xms2000m, -jar, /GenomeAnalysisTK.jar]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      -T PrintReads
      -I $(inputs.input_bam.path)
      -R $(inputs.reference.path)
      --interval_padding 500
      -L $(inputs.interval_list.path)
      -o local.sharded.bam && java -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -Xms8000m
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
