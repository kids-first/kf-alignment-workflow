cwlVersion: v1.2
class: CommandLineTool
id: sentieon_collectvcmetrics
doc: |-
  The CollectVCMetrics algorithm collects metrics related to the variants present in the input VCF.

  The input to the CollectVCMetrics algorithm is a VCF file and a DBSNP file; its output is a pair of files containing information about the variants from the VCF file.
  Example usage:
    driver -r reference.fasta [driver_options] \
      --algo CollectVCMetrics [algo_options] --vcf/-v input.vcf \
      --dbsnp/-d dbsnp.vcf outputPrefix

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
      driver --thread_count \$(nproc)
  - position: 10
    shellQuote: false
    valueFrom: >
      --algo CollectVCMetrics

inputs:
  sentieon_license: { type: 'string', doc: "License server host and port" }
  output_prefix: { type: 'string', inputBinding: { position: 19 }, doc: "Prefix for output filenames." }

  # Driver Arguments
  indexed_reference_fasta: { type: 'File', secondaryFiles: [{ pattern: '.fai', required: true }, { pattern: '^.dict', required: true }], inputBinding: { position: 2, prefix: "--reference"}, doc: "Reference file (FASTA)", "sbg:fileTypes": "FA, FASTA" }
  input_reads: { type: 'File[]?', secondaryFiles: [{ pattern: '.bai', required: false}, { pattern: '^.bai', required: false }, { pattern: '.crai', required: false}, { pattern: '^.crai', required: false }], inputBinding: { position: 2, prefix: "--input", itemSeparator: "--input ", shellQuote: false }, doc: "Read sequence input file (BAM/CRAM)", "sbg:fileTypes": "BAM, CRAM" }
  qual_cal: { type: 'File[]?', inputBinding: { position: 2, prefix: "--qual_cal", itemSeparator: " --qual_cal ", shellQuote: false }, doc: "Base quality calibration table" }
  interval: { type: 'File?', inputBinding: { position: 2, prefix: "--interval"}, doc: "Interval file (BED/Picard)", "sbg:fileTypes": "BED, LIST, INTERVAL_LIST" }
  interval_padding: { type: 'int?', inputBinding: { position: 2, prefix: "--interval_padding"}, doc: "Amount to pad all intervals" }
  skip_no_coor: { type: 'boolean?', inputBinding: { position: 2, prefix: "--skip_no_coor"}, doc: "Skip unmapped reads" }
  cram_read_options: { type: 'string?', inputBinding: { position: 2, prefix: "--cram_read_options"}, doc: "CRAM read options" }
  read_filter: { type: 'string?', inputBinding: { position: 2, prefix: "--read_filter"}, doc: "Read filter name and params" }

  # CollectVCMetrics Arguments
  dbsnp: { type: 'File?', secondaryFiles: [{ pattern: '.idx', required: false }, { pattern: '.tbi', required: false }], inputBinding: { position: 12, prefix: "--dbsnp"}, doc: "dbSNP file", "sbg:fileTypes": "VCF, VCF.GZ" }
  vcf: { type: 'File?', secondaryFiles: [{ pattern: '.tbi', required: false }], inputBinding: { position: 12, prefix: "--vcf"}, doc: "Input VCF file for analysis" }

  conditional: { type: 'boolean?', doc: "Hook to disable this tool when wrapped in a workflow" }

  cpu:
    type: 'int?'
    default: 8
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 8
    doc: "GB size of RAM to allocate to this task."

outputs:
  output:
    type: File[]
    outputBinding:
      glob: "$(inputs.output_prefix)*"

$namespaces:
  sbg: https://sevenbridges.com
