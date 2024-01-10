cwlVersion: v1.2
class: CommandLineTool
id: sentieon_haplotyper
doc: |-
  Sentieon Haplotyper tool.
  Example usage:
    # Single sample GVCF Creation
    driver -r REFERENCE -t NUMBER_THREADS -i ${sample}_DEDUPED_BAM \
      -q ${sample}_RECAL_DATA_TABLE --algo Haplotyper --emit_mode gvcf \
      ${sample}_VARIANT_GVCF
    # Single sample GVCF Creation Using RECALIBRATED BAM
    driver -r REFERENCE -t NUMBER_THREADS -i REACAL_BAM \
      --algo Haplotyper --emit_mode gvcf \
      ${sample}_VARIANT_GVCF
    # Joint VCF Creation
    driver -t NUMBER_THREADS -i s1_DEDUPED_BAM -q s1_RECAL_DATA_TABLE \
      -i s2_DEDUPED_BAM -q s2_RECAL_DATA_TABLE -i s3_DEDUPED_BAM \
      -q s3_RECAL_DATA_TABLE --algo Haplotyper VARIANT_VCF

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
      --algo Haplotyper

inputs:
  sentieon_license: { type: 'string', doc: "License server host and port" }
  output_filename: { type: 'string', inputBinding: { position: 19 }, doc: "Name for output VCF or VCF.GZ. Naming file GZ will compress the output." }

  # Driver Arguments
  indexed_reference_fasta: { type: 'File', secondaryFiles: [{ pattern: '.fai', required: true }, { pattern: '^.dict', required: true }], inputBinding: { position: 2, prefix: "--reference"}, doc: "Reference file (FASTA)", "sbg:fileTypes": "FA, FASTA" }
  input_reads: { type: 'File[]', secondaryFiles: [{ pattern: '.bai', required: false}, { pattern: '^.bai', required: false }, { pattern: '.crai', required: false}, { pattern: '^.crai', required: false }], inputBinding: { position: 2, prefix: "--input", itemSeparator: "--input ", shellQuote: false }, doc: "Read sequence input file (BAM/CRAM)", "sbg:fileTypes": "BAM, CRAM" }
  qual_cal: { type: 'File[]?', inputBinding: { position: 2, prefix: "--qual_cal", itemSeparator: " --qual_cal ", shellQuote: false }, doc: "Base quality calibration table" }
  interval: { type: 'File?', inputBinding: { position: 2, prefix: "--interval"}, doc: "Interval file (BED/Picard)", "sbg:fileTypes": "BED, LIST, INTERVAL_LIST" }
  interval_padding: { type: 'int?', inputBinding: { position: 2, prefix: "--interval_padding"}, doc: "Amount to pad all intervals" }
  skip_no_coor: { type: 'boolean?', inputBinding: { position: 2, prefix: "--skip_no_coor"}, doc: "Skip unmapped reads" }
  cram_read_options: { type: 'string?', inputBinding: { position: 2, prefix: "--cram_read_options"}, doc: "CRAM read options" }
  read_filter: { type: 'string?', inputBinding: { position: 2, prefix: "--read_filter"}, doc: "Read filter name and params" }

  # Haplotyper Arguments
  annotation: { type: 'string?', inputBinding: { position: 12, prefix: "--annotation"}, doc: "Annotations to include, or exclude using '!' prefix" }
  dbsnp: { type: 'File?', secondaryFiles: [{ pattern: '.idx', required: false }, { pattern: '.tbi', required: false }], inputBinding: { position: 12, prefix: "--dbsnp"}, doc: "dbSNP file", "sbg:fileTypes": "VCF, VCF.GZ" }
  call_conf: { type: 'int?', inputBinding: { position: 12, prefix: "--call_conf"}, doc: "Call confidence level (default: 30)" }
  emit_conf: { type: 'int?', inputBinding: { position: 12, prefix: "--emit_conf"}, doc: "Emit confidence level (default: 30)" }
  emit_mode: { type: 'string?', inputBinding: { position: 12, prefix: "--emit_mode"}, doc: "Emit mode: variant, confident, all or gvcf (default: variant)" }
  genotype_model: { type: 'string?', inputBinding: { position: 12, prefix: "--genotype_model"}, doc: "Genotype model: coalescent or multinomial (default: coalescent)" }
  given: { type: 'File?', secondaryFiles: [{ pattern: '.tbi', required: false }], inputBinding: { position: 12, prefix: "--given"}, doc: "Call only the variants given in this vcf file" }
  gq_bands: { type: 'string?', inputBinding: { position: 12, prefix: "--gq_bands"}, doc: "GQ band thresholds (default: 1-60,60-99/10,99)" }
  min_base_qual: { type: 'int?', inputBinding: { position: 12, prefix: "--min_base_qual"}, doc: "Minimum base quality to consider (default: 10)" }
  pcr_indel_model: { type: 'string?', inputBinding: { position: 12, prefix: "--pcr_indel_model"}, doc: "PCR indel error model: none, hostile, aggressive, or conservative (default: conservative)" }
  phasing: { type: 'string?', inputBinding: { position: 12, prefix: "--phasing"}, doc: "Disable/enable phasing: 0 or 1 (default: 1) (applicable only to diploid in gvcf mode)" }
  ploidy: { type: 'int?', inputBinding: { position: 12, prefix: "--ploidy"}, doc: "Sample ploidy (default: 2)" }
  prune_factor: { type: 'int?', inputBinding: { position: 12, prefix: "--prune_factor"}, doc: "Pruning factor in the kmer graph (default: 2)" }
  trim_soft_clip: { type: 'boolean?', inputBinding: { position: 12, prefix: "--trim_soft_clip"}, doc: "Trim off soft-clipped bases" }

  conditional: { type: 'boolean?', doc: "Hook to disable this tool when wrapped in a workflow" }

  cpu:
    type: 'int?'
    default: 32
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 32
    doc: "GB size of RAM to allocate to this task."

outputs:
  recalibrated_reads:
    type: 'File?'
    secondaryFiles: [{ pattern: '.bai', required: false }, { pattern: '.crai', required: false }]
    outputBinding:
      glob: "*.*am"
  output:
    type: File
    secondaryFiles: [{ pattern: '.tbi', required: false }]
    outputBinding:
      glob: $(inputs.output_filename)

$namespaces:
  sbg: https://sevenbridges.com
