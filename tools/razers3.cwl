class: CommandLineTool
cwlVersion: v1.2
id: razers3 
doc: "Razers3 aligner"
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'images.sbgenomics.com/bojana_smiljanic/optitype-1-3-5:1'
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
baseCommand: [/opt/razers3-3.4.0-Linux-x86_64/bin/razers3]
inputs:
  # I/O 
  reads: { type: 'File', doc: "Fastq file containing the reads (R1)." }
  mates: { type: 'File?', doc: "Fastq file containing the mates (R2)." }
  indexed_reference_fasta: { type: 'File', secondaryFiles: [{ pattern: '.fai', required: true }], doc: "Reference fasta and fai index." }
  output_filename: { type: 'string?', inputBinding: { position: 2, prefix: "--output"}, doc: "Mapping result filename (use - to dump to stdout in razers format). Default: <READS FILE>.razers. Valid filetypes are: .razers, .eland, .fa, .fasta, .gff, .sam, .bam, and .afg." }

  # Main Options:
  percent_identity: { type: 'int?', inputBinding: { position: 2, prefix: "--percent-identity"}, doc: "Percent identity threshold. In range [50..100]. Default: 95." }
  recognition_rate: { type: 'int?', inputBinding: { position: 2, prefix: "--recognition-rate"}, doc: "Percent recognition rate. In range [80..100]. Default: 99." }
  no_gaps: { type: 'boolean?', inputBinding: { position: 2, prefix: "--no-gaps"}, doc: "Allow only mismatches, no indels. Default: allow both." }
  forward: { type: 'boolean?', inputBinding: { position: 2, prefix: "--forward"}, doc: "Map reads only to forward strands." }
  reverse: { type: 'boolean?', inputBinding: { position: 2, prefix: "--reverse"}, doc: "Map reads only to reverse strands." }
  max_hits: { type: 'int?', inputBinding: { position: 2, prefix: "--max-hits"}, doc: "Output only <NUM> of the best hits. In range [1..inf]. Default: 100." }
  unique: { type: 'boolean?', inputBinding: { position: 2, prefix: "--unique"}, doc: "Output only unique best matches (-m 1 -dr 0 -pa)." }
  trim_reads: { type: 'int?', inputBinding: { position: 2, prefix: "--trim-reads"}, doc: "Trim reads to given length. Default: off. In range [14..inf]." }
  verbose: { type: 'boolean?', inputBinding: { position: 2, prefix: "--verbose"}, doc: "Verbose mode." }
  vverbose: { type: 'boolean?', inputBinding: { position: 2, prefix: "--vverbose"}, doc: "Very verbose mode." }

  # Paired-end Options:
  library_length: { type: 'int?', inputBinding: { position: 2, prefix: "--library-length" }, doc: "Paired-end library length. In range [1..inf]. Default: 220." }
  library_error: { type: 'int?', inputBinding: { position: 2, prefix: "--library-error" }, doc: "Paired-end library length tolerance. In range [0..inf]. Default: 50." }

  # Output Format Options:
  alignment: { type: 'boolean?', inputBinding: { position: 2, prefix: "--alignment" }, doc: "Dump the alignment for each match (only razer or fasta format)." }
  purge_ambiguous: { type: 'boolean?', inputBinding: { position: 2, prefix: "--purge-ambiguous" }, doc: "Purge reads with more than <max-hits> best matches." }
  distance_range: { type: 'int?', inputBinding: { position: 2, prefix: "--distance-range" }, doc: "Only consider matches with at most NUM more errors compared to the best. Default: output all." }
  genome_naming: { type: 'int?', inputBinding: { position: 2, prefix: "--genome-naming" }, doc: "Select how genomes are named (see Naming section below). In range [0..1]. Default: 0." }
  read_naming: { type: 'int?', inputBinding: { position: 2, prefix: "--read-naming" }, doc: "Select how reads are named (see Naming section below). In range [0..3]. Default: 0." }
  full_readid: { type: 'boolean?', inputBinding: { position: 2, prefix: "--full-readid" }, doc: "Use the whole read id (don't clip after whitespace)." }
  sort_order: { type: 'int?', inputBinding: { position: 2, prefix: "--sort-order" }, doc: "Select how matches are sorted (see Sorting section below). In range [0..1]. Default: 0." }
  position_format: { type: 'int?', inputBinding: { position: 2, prefix: "--position-format" }, doc: "Select begin/end position numbering (see Coordinate section below). In range [0..1]. Default: 0." }
  dont_shrink_alignments: { type: 'boolean?', inputBinding: { position: 2, prefix: "--dont-shrink-alignments" }, doc: "Disable alignment shrinking in SAM. This is required for generating a gold mapping for Rabema." }

  # Filtration Options:
  filter: { type: 'string?', inputBinding: { position: 2, prefix: "--filter" }, doc: "Select k-mer filter. One of pigeonhole and swift. Default: pigeonhole." }
  mutation_rate: { type: 'float?', inputBinding: { position: 2, prefix: "--mutation-rate" }, doc: "Set the percent mutation rate (pigeonhole). In range [0..20]. Default: 5." }
  overlap_length: { type: 'int?', inputBinding: { position: 2, prefix: "--overlap-length" }, doc: "Manually set the overlap length of adjacent k-mers (pigeonhole). In range [0..inf]." }
  param_dir: { type: 'string?', inputBinding: { position: 2, prefix: "--param-dir" }, doc: "Read user-computed parameter files in the directory <DIR> (swift)." }
  threshold: { type: 'int?', inputBinding: { position: 2, prefix: "--threshold" }, doc: "Manually set minimum k-mer count threshold (swift). In range [1..inf]." }
  taboo_length: { type: 'int?', inputBinding: { position: 2, prefix: "--taboo-length" }, doc: "Set taboo length (swift). In range [1..inf]. Default: 1." }
  shape: { type: 'string?', inputBinding: { position: 2, prefix: "--shape" }, doc: "Manually set k-mer shape." }
  overabundance_cut: { type: 'int?', inputBinding: { position: 2, prefix: "--overabundance-cut" }, doc: "Set k-mer overabundance cut ratio. In range [0..1]. Default: 1." }
  repeat_length: { type: 'int?', inputBinding: { position: 2, prefix: "--repeat-length" }, doc: "Skip simple-repeats of length <NUM>. In range [1..inf]. Default: 1000." }
  load_factor: { type: 'float?', inputBinding: { position: 2, prefix: "--load-factor" }, doc: "Set the load factor for the open addressing k-mer index. In range [1..inf]. Default: 1.6." }

  # Verification Options:
  match_N: { type: 'boolean?', inputBinding: { position: 2, prefix: "--match-N"}, doc: "N matches all other characters. Default: N matches nothing." }
  error_distr: { type: 'string?', inputBinding: { position: 2, prefix: "--error-distr"}, doc: "Write error distribution to FILE." }
  mismatch_file: { type: 'string?', inputBinding: { position: 2, prefix: "--mismatch-file"}, doc: "Write mismatch patterns to FILE." }

  # Misc Options:
  compact_mult: { type: 'float?', inputBinding: { position: 2, prefix: "--compact-mult"}, doc: "Multiply compaction treshold by this value after reaching and compacting. In range [0..inf]. Default: 2.2." }
  no_compact_frac: { type: 'float?', inputBinding: { position: 2, prefix: "--no-compact-frac"}, doc: "Don't compact if in this last fraction of genome. In range [0..1]. Default: 0.05." }

  # Parallelism Options:
  thread_count: { type: 'int?', inputBinding: { position: 2, prefix: "--thread-count"}, doc: "Set the number of threads to use (0 to force sequential mode). In range [0..inf]. Default: 1." }
  parallel_window_size: { type: 'int?', inputBinding: { position: 2, prefix: "--parallel-window-size"}, doc: "Collect candidates in windows of this length. In range [1..inf]. Default: 500000." }
  parallel_verification_size: { type: 'int?', inputBinding: { position: 2, prefix: "--parallel-verification-size"}, doc: "Verify candidates in packages of this size. In range [1..inf]. Default: 100." }
  parallel_verification_max_package_count: { type: 'int?', inputBinding: { position: 2, prefix: "--parallel-verification-max-package-count"}, doc: "Largest number of packages to create for verification per thread-1. In range [1..inf]. Default: 100." }
  available_matches_memory_size: { type: 'int?', inputBinding: { position: 2, prefix: "--available-matches-memory-size"}, doc: "Bytes of main memory available for storing matches. In range [-1..inf]. Default: 0." }
  match_histo_start_threshold: { type: 'int?', inputBinding: { position: 2, prefix: "--match-histo-start-threshold"}, doc: "When to start histogram. In range [1..inf]. Default: 5." }

  cpu: { type: 'int?', default: 16, doc: "CPUs to allocate to this task" }
  ram: { type: 'int?', default: 32, doc: "GB of ram to allocate to this task" }
outputs:
  output:
    type: File
    outputBinding:
      glob: |
        $(inputs.output_filename ? inputs.output_filename : "*.razers")
