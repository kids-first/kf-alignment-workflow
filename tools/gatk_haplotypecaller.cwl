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
      --interval_padding 500
      -L $(inputs.interval_list.path)
      -O local.sharded.bam
  - position: 2
    shellQuote: false
    valueFrom: >-
      && java -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -Xms8000m
      -jar /GenomeAnalysisTK.jar
      -T HaplotypeCaller
      -o $(inputs.input_bam.nameroot).vcf.gz
      -I local.sharded.bam
      -L $(inputs.interval_list.path)
      --read_filter OverclippedRead
inputs:
  reference: { type: File, secondaryFiles: [^.dict, .fai], doc: "Reference fasta with associated dict and fai indexes", inputBinding: { position: 2, prefix: "-R" } }
  input_bam: { type: File, secondaryFiles: [^.bai], doc: "Input bam file", inputBinding: { position: 1, prefix: "-I" } }
  erc: { type: ['null', {type: enum, name: erc, symbols: ["NONE", "BP_RESOLUTION", "GVCF"]}], default: "GVCF",
  doc: "Mode for emitting reference confidence scores.", inputBinding: { position: 2, prefix: '-ERC' } }
  max_alternate_alleles: { type: 'int?', doc: "Maximum number of alternate alleles to genotype", default: 3,
  inputBinding: { position: 2, prefix: "--max_alternate_alleles" } }
  variant_index_parameter: { type: 'int?', doc: "Value must be set for ERC mode GVCF to index properly", default: 128000,
  inputBinding: { position: 2, prefix: "-variant_index_parameter" } }
  variant_index_type: { type: ['null', {type: enum, name: erc, symbols: ["DYNAMIC_SEEK", "DYNAMIC_SIZE", "LINEAR", "INTERVAL"]}], default: "LINEAR",
  doc: "Type of index - must be LINEAR for ERC mode GVCF.", inputBinding: { position: 2, prefix: '-variant_index_type' } }
  interval_list: { type: File, doc: "File containing one or more genomic intervals over which to operate" }
  contamination: { type: 'float?', doc: "Fraction of contamination in sequencing data (for all samples) to aggressively remove" , inputBinding: { position: 2, prefix: "-contamination" } }
outputs:
  output: { type: File, outputBinding: { glob: '*.vcf.gz' }, secondaryFiles: [.tbi] }
