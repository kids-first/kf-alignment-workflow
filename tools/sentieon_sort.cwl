cwlVersion: v1.2
class: CommandLineTool
id: sentieon_sort
doc: |-
  sort a BAM file
requirements:
- class: ShellCommandRequirement
- class: InlineJavascriptRequirement
- class: ResourceRequirement
  coresMin: $(inputs.cpu)
  ramMin: $(inputs.ram * 1000) 
- class: DockerRequirement
  dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202112.01_hifi
- class: EnvVarRequirement
  envDef:
  - envName: SENTIEON_LICENSE
    envValue: $(inputs.sentieon_license)

baseCommand: [sentieon, util, sort]

inputs:
  sentieon_license: { type: 'string?', default: "10.5.59.108:8990", doc: "License server host and port" }
  reference: { type: File, inputBinding: { position: 1, prefix: "-r" }, secondaryFiles: [{pattern: '.fai', required: true}, {pattern: '^.dict', required: true}, {pattern: '.64.amb', required: true}, {pattern: '.64.ann', required: true}, {pattern: '.64.bwt', required: true}, {pattern: '.64.pac', required: true}, {pattern: '.64.sa', required: true}, {pattern: '.64.alt', required: false}], 'sbg:fileTypes': 'FA, FASTA', doc: "Reference fasta file with associated indexes" } 
  input_reads: { type: File, inputBinding: { position: 1, prefix: "-i" }, secondaryFiles: [{pattern: '.bai', required: false}, {pattern: '^.bai', required: false}], doc: "Input unsorted BAM or SAM" }
  bam_compression: { type: 'int?', inputBinding: { position: 1, prefix: "--bam_compression" }, doc: "gzip compression level for the output BAM file." }
  sam2bam: { type: 'boolean?', inputBinding: { position: 1, prefix: "--sam2bam" }, doc: "indicates that the input will be in the form of an uncompressed SAM file, that needs to be converted to BAM. If this option is not used, the input should have been converted to BAM format from the BWA output using samtools." }
  block_size: { type: 'int?', inputBinding: { position: 1, prefix: "--block_size" }, doc: "size of the block to be used for sorting." }
  umi_post_process: { type: 'boolean?', inputBinding: { position: 1, prefix: "--umi_post_process" }, doc: "indicates that the input comes from next-generation sequence data containing molecular barcode information (also called unique molecular indices or UMIs) processed by the sentieon umi consensus tool. This option instructs the tool to perform the necessary post-processing for this kind of data." }
  output_filename: { type: string, inputBinding: { position: 1, prefix: "-o" }, doc: "String to use as the name for the output." }
  cpu: { type: 'int?', default: 32, inputBinding: { position: 1, prefix: "-t" }, doc: "Cores to allocate to this task." }
  ram: { type: 'int?', default: 32, doc: "GB of RAM to allocate to this task." }

outputs:
  output:
    type: File
    outputBinding:
      glob: "*.*am"
    secondaryFiles: [{ pattern: '.bai', required: true }, { pattern: '.crai', required: true}]

$namespaces:
  sbg: https://sevenbridges.com
