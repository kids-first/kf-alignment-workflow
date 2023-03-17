cwlVersion: v1.2
class: CommandLineTool
id: samtools_collate_fastq
doc: |-
  This tool collates an BAM/CRAM/SAM file then splits it into fastqs.
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'staphb/samtools:1.16.1'
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.collate_cpu + inputs.fastq_cpu)
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      samtools collate
  - position: 10
    prefix: "|"
    shellQuote: false
    valueFrom: >-
      samtools fastq
inputs:
  # Input
  input_reads: { type: 'File', inputBinding: { position: 9 }, doc: "Input BAM/CRAM/SAM file" }

  # Collate Options
  print_stdout: { type: 'boolean?', inputBinding: { position: 2, prefix: "-O" }, doc: "output to stdout" }
  output_filename: { type: 'string?', inputBinding: { position: 2, prefix: "-o" }, doc: "output file name (use prefix if not set)" }
  uncompressed_bamout: { type: 'boolean?', inputBinding: { position: 2, prefix: "-u" }, doc: "uncompressed BAM output" }
  compression_level_collate: { type: 'int?', inputBinding: { position: 2, prefix: "-l" }, doc: "compression level [1]" }
  num_temp_files: { type: 'int?', inputBinding: { position: 2, prefix: "-n" }, doc: "number of temporary files [64]" }
  input_fmt_option_collate: { type: 'string?', inputBinding: { position: 2, prefix: "--input-fmt-option" }, doc: "Specify a single input file format option in the form of OPTION or OPTION=VALUE" }
  output_fmt: { type: 'string?', inputBinding: { position: 2, prefix: "--output-fmt" }, doc: "Specify output format (SAM, BAM, CRAM)" }
  output_fmt_option: { type: 'string?', inputBinding: { position: 2, prefix: "--output-fmt-option" }, doc: "Specify a single output file format option in the form of OPTION or OPTION=VALUE" }
  reference: { type: 'File?', inputBinding: { position: 2, prefix: "--reference" }, doc: "Reference sequence FASTA FILE [null]" }
  collate_cpu: { type: 'int?', default: 4, inputBinding: { position: 2, prefix: "--threads" }, doc: "CPUs to allocate to samtools collate" }

  # Fastq Options
  outfile_r1_or_r2: { type: 'string?', inputBinding: { position: 12, prefix: "-0" }, doc: "write paired reads flagged both or neither READ1 and READ2 to FILE" }
  outfile_r1: { type: 'string?', inputBinding: { position: 12, prefix: "-1" }, doc: "write paired reads flagged READ1 to FILE" }
  outfile_r2: { type: 'string?', inputBinding: { position: 12, prefix: "-2" }, doc: "write paired reads flagged READ2 to FILE" }
  outfile_singletons: { type: 'string?', inputBinding: { position: 12, prefix: "-s" }, doc: "write singleton reads to FILE [assume single-end]" }
  include_all_flags: { type: 'int?', inputBinding: { position: 12, prefix: "-f" }, doc: "only include reads with all  of the FLAGs in INT present [0]" }
  include_none_flags: { type: 'int?', inputBinding: { position: 12, prefix: "-F" }, doc: "only include reads with none of the FLAGS in INT present [0]" }
  exclude_all_flags: { type: 'int?', inputBinding: { position: 12, prefix: "-G" }, doc: "only EXCLUDE reads with all  of the FLAGs in INT present [0]" }
  donot_append_rnames: { type: 'boolean?', inputBinding: { position: 12, prefix: "-n" }, doc: "don't append /1 and /2 to the read name" }
  always_append_rnames: { type: 'boolean?', inputBinding: { position: 12, prefix: "-N" }, doc: "always append /1 and /2 to the read name" }
  output_quality: { type: 'boolean?', inputBinding: { position: 12, prefix: "-O" }, doc: "output quality in the OQ tag if present" }
  copy_tags: { type: 'boolean?', inputBinding: { position: 12, prefix: "-t" }, doc: "copy RG, BC and QT tags to the FASTQ header line" }
  copy_tags_arb: { type: 'boolean?', inputBinding: { position: 12, prefix: "-T" }, doc: "copy arbitrary tags to the FASTQ header line" }
  default_qualscore: { type: 'int?', inputBinding: { position: 12, prefix: "-v" }, doc: "default quality score if not given in file [1]" }
  illumina_casva: { type: 'boolean?', inputBinding: { position: 12, prefix: "-i" }, doc: "add Illumina Casava 1.8 format entry to header (eg 1:N:0:ATCACG)" }
  compression_level_fastq: { type: 'int?', inputBinding: { position: 12, prefix: "-c" }, doc: "compression level [0..9] to use when creating gz or bgzf fastq files" }
  i1: { type: 'string?', inputBinding: { position: 12, prefix: "--i1" }, doc: "write first index reads to FILE" }
  i2: { type: 'string?', inputBinding: { position: 12, prefix: "--i2" }, doc: "write second index reads to FILE" }
  barcode_tag: { type: 'string?', inputBinding: { position: 12, prefix: "--barcode-tag" }, doc: "Barcode tag [default: BC]" }
  quality_tag: { type: 'string?', inputBinding: { position: 12, prefix: "--quality-tag" }, doc: "Quality tag [default: QT]" }
  index_format: { type: 'string?', inputBinding: { position: 12, prefix: "--index-format" }, doc: "How to parse barcode and quality tags" }
  input_fmt_option_fastq: { type: 'string?', inputBinding: { position: 12, prefix: "--input-fmt-option" }, doc: "Specify a single input file format option in the form of OPTION or OPTION=VALUE" }
  fastq_cpu: { type: 'int?', default: 8, inputBinding: { position: 12, prefix: "--threads" },  doc: "CPUs to allocate to samtools fastq" }

  ram: { type: 'int?', default: 16, doc: "GB of RAM to allocate to this task" }
outputs:
  reads_1:
    type: File?
    outputBinding:
      glob: $(inputs.outfile_r1)
  reads_2:
    type: File?
    outputBinding:
      glob: $(inputs.outfile_r2)
  reads_12:
    type: File?
    outputBinding:
      glob: $(inputs.outfile_r1_or_r2)
  reads_s:
    type: File?
    outputBinding:
      glob: $(inputs.outfile_singletons)
