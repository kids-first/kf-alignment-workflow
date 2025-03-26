cwlVersion: v1.2
class: CommandLineTool
id: sentieon_gvcftyper
doc: |-
  Sentieon GVCFtyper tool.
  Usage for GVCFtyper:
    driver -r reference.fasta [driver_options] \
           --algo GVCFtyper -v input.g.vcf[.gz] [algo_options] output.vcf[.gz]
  Or,
    driver -r reference.fasta [driver_options] \
           --algo GVCFtyper [algo_options] output.vcf[.gz] input.g.vcf[.gz] ...

requirements:
- class: ShellCommandRequirement
- class: InlineJavascriptRequirement
- class: DockerRequirement
  dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202112.01_hifi
- class: ResourceRequirement
  coresMin: $(inputs.cpu)
  ramMin: $(inputs.ram * 1000)
- class: EnvVarRequirement
  envDef:
  - envName: SENTIEON_LICENSE
    envValue: $(inputs.sentieon_license)

baseCommand: [sentieon]

arguments:
  - position: 1
    shellQuote: false
    valueFrom: >
      driver -t \$(nproc)
  - position: 10
    shellQuote: false
    valueFrom: >
      --algo GVCFtyper

inputs:
  # Required Arguments
  sentieon_license: { type: 'string', doc: "License server host and port" }
  indexed_reference_fasta: { type: 'File', secondaryFiles: [{ pattern: '.fai', required: true }, { pattern: '^.dict', required: true }], inputBinding: { position: 2, prefix: "--reference"}, doc: "Reference file (FASTA)", "sbg:fileTypes": "FA, FASTA" }
  vcf: { type: 'File', inputBinding: { position: 12, prefix: "--vcf" }, doc: "Input gVCF file", secondaryFiles: ['.tbi'] }
  output_filename: { type: 'string', inputBinding: { position: 19 }, doc: "Name for output VCF or VCF.GZ. Naming file GZ will compress the output." }

  # Driver Arguments
  input_reads: { type: 'File[]?', secondaryFiles: [{ pattern: '.bai', required: false}, { pattern: '^.bai', required: false }, { pattern: '.crai', required: false}, { pattern: '^.crai', required: false }], inputBinding: { position: 2, prefix: "--input", itemSeparator: "--input ", shellQuote: false }, doc: "Read sequence input file (BAM/CRAM)", "sbg:fileTypes": "BAM, CRAM" }
  qual_cal: { type: 'File[]?', inputBinding: { position: 2, prefix: "--qual_cal", itemSeparator: " --qual_cal ", shellQuote: false }, doc: "Base quality calibration table" }
  interval: { type: 'File?', inputBinding: { position: 2, prefix: "--interval"}, doc: "Interval file (BED/Picard)", "sbg:fileTypes": "BED, LIST, INTERVAL_LIST" }
  interval_padding: { type: 'int?', inputBinding: { position: 2, prefix: "--interval_padding"}, doc: "Amount to pad all intervals" }
  skip_no_coor: { type: 'boolean?', inputBinding: { position: 2, prefix: "--skip_no_coor"}, doc: "Skip unmapped reads" }
  cram_read_options: { type: 'string?', inputBinding: { position: 2, prefix: "--cram_read_options"}, doc: "CRAM read options" }
  read_filter: { type: 'string?', inputBinding: { position: 2, prefix: "--read_filter"}, doc: "Read filter name and params" }

  # GVCFtyper Arguments
  annotation: { type: 'string?', inputBinding: { position: 12, prefix: "--annotation" }, doc: "Annotations to include, or exclude using '!' prefix" }
  dbsnp: { type: 'File?', inputBinding: { position: 12, prefix: "--dbsnp" }, doc: "dbSNP file", secondaryFiles: [{ pattern: '.tbi', required: false}, { pattern: '.idx', required: false} ] }
  call_conf: { type: 'int?', inputBinding: { position: 12, prefix: "--call_conf" }, doc: "Call confidence level (default: 30)" }
  emit_conf: { type: 'int?', inputBinding: { position: 12, prefix: "--emit_conf" }, doc: "Emit confidence level (default: 30)" }
  emit_mode: { type: ['null', {type: 'enum', name: genotype_model, symbols: ["variant", "confident", "all"]}], inputBinding: { position: 12, prefix: "--emit_mode" }, doc: "Emit mode: variant, confident or all (default: variant)" }
  genotype_model: { type: ['null', {type: 'enum', name: genotype_model, symbols: ["multinomial", "coalescent"]}],
    inputBinding: { position: 12, prefix: "--genotype_model" }, doc: "Genotype model: coalescent (GATK3.8) or multinomial (GATK4.1) (default: coalescent)" }
  max_alt_alleles: { type: 'int?', inputBinding: { position: 12, prefix: "--max_alt_alleles" }, doc: "Maximum number of alternate alleles (default: 100)" }

  cpu:
    type: 'int?'
    default: 8
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 16
    doc: "GB size of RAM to allocate to this task."

outputs:
  output:
    type: File
    secondaryFiles: [{ pattern: '.tbi', required: false }]
    outputBinding:
      glob: $(inputs.output_filename)

$namespaces:
  sbg: https://sevenbridges.com
