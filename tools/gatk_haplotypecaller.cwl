cwlVersion: v1.0
class: CommandLineTool
id: gatk_haplotypecaller
doc: |-
  This tool calls germline SNPs and indels via local re-assembly of haplotypes.
  The following programs are run in this tool:
    - GATK PrintReads
    - GATK HaplotypeCaller
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 10000
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.beta.1-3.5'
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
  reference: { type: File, secondaryFiles: [^.dict, .fai], doc: "Reference fasta with associated dict and fai indexes" }
  input_bam: { type: File, secondaryFiles: [^.bai], doc: "Input bam file" }
  interval_list: { type: File, doc: "File containing one or more genomic intervals over which to operate" }
  contamination: { type: float, doc: "Fraction of contamination in sequencing data (for all samples) to aggressively remove" }
outputs:
  output: { type: File, outputBinding: { glob: '*.vcf.gz' }, secondaryFiles: [.tbi] }
