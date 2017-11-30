cwlVersion: v1.0
class: CommandLineTool
id: gatk_haplotypecaller
baseCommand: [/usr/bin/java, -jar, /GenomeAnalysisTK.jar]
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:3.6-0-g89b7209'
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      -T HaplotypeCaller
      -R $(inputs.reference.path)
      -o $(inputs.input_bam.nameroot).vcf.gz
      -I $(inputs.input_bam.path)
      -L $(inputs.interval_list.path)
      -ERC GVCF
      --max_alternate_alleles 3
      -variant_index_parameter 128000
      -variant_index_type LINEAR
      -contamination 0
      --read_filter OverclippedRead
inputs:
  reference:
    type: File
    secondaryFiles: [^.dict, .fai]
  input_bam:
    type: File
  interval_list:
    type: File
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles:
      - .tbi
