cwlVersion: v1.2
class: CommandLineTool
id: cutadapt
doc: |
  Using an interleaved FASTQ file input, use cutadapt to:
  - Trim bases with quality less than quality_cutoff from the 3' and 5' ends of the reads
  - Trim r1_threeprime_adapter from the 3' of read1
  - Trim r2_threeprime_adapter from the 3' of read2
  - Discard any read pairs that have a read shorter than 20 bases
  - Return the resulting reads as an interleaved FASTQ
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: '684194535433.dkr.ecr.us-east-1.amazonaws.com/d3b-healthomics:cutadapt-4.6'
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.cpu)
    ramMin: $(inputs.ram * 1000)
baseCommand: [cutadapt]
stdout: $(inputs.outputname_stats)
inputs:
  input_reads1: { type: 'File', inputBinding: { position: 8 }, doc: "FASTQ file containing reads1 or interleaved reads." }
  input_reads2: { type: 'File?', inputBinding: { position: 9 },  doc: "FASTQ file containing reads2." }
  interleaved: { type: 'boolean?', inputBinding: { position: 2, prefix: "--interleaved" }, doc: "Read and/or write interleaved paired-end reads." }
  r1_threeprime_adapter: { type: 'string', inputBinding: { position: 2, prefix: "-a" }, doc: "regular 3' adapter sequence to remove from read1" }
  r2_threeprime_adapter: { type: 'string?', inputBinding: { position: 2, prefix: "-A" }, doc: "regular 3' adapter sequence to remove from read2" }
  minimum_length: { type: 'int?', default: 20, inputBinding: { position: 2, prefix: "--minimum-length" }, doc: "If you do not use this option, reads that have a length of zero (empty reads) are kept in the output" }
  quality_base: { type: 'int?', default: 33, inputBinding: { position: 2, prefix: "--quality-base" }, doc: "Phred scale used" }
  quality_cutoff: {type: 'string?', default: "0", inputBinding: { position: 2, prefix: "--quality-cutoff" }, doc: "Quality trim cutoff. If you specify a single cutoff value, the 3' end of each read is trimmed. If you specify two cutoff values separated by a comma, the first value will be trimmed from the 5' and the second value will be trimmed from the 3'" }
  outputname_reads1: { type: 'string?', default: "reads1.trimmed.fastq", inputBinding: { position: 2, prefix: "--output" }, doc: "Write trimmed reads to FILE. Can be FASTQ or FASTA format" }
  outputname_reads2: { type: 'string?', inputBinding: { position: 2, prefix: "--paired-output" }, doc: "Write R2 to FILE." }
  outputname_stats: { type: 'string?', default: "cutadapt_stats.txt", doc: "Name for stats output file." }
  additional_args: {type: 'string?', inputBinding: { position: 2, shellQuote: false }, doc: "Any additional args to be set"}
  cpu: { type: 'int?', default: 8, inputBinding: { position: 2, prefix: "--cores" }, doc: "CPUs to allocate to this task" }
  ram: { type: 'int?', default: 16, doc: "GB of RAM to allocate to this task" }
outputs:
  trimmed_output:
    type: File
    outputBinding:
      glob: $(inputs.outputname_reads1) 
  trimmed_paired_output:
    type: File
    outputBinding:
      glob: $(inputs.outputname_reads2)
  cutadapt_stats:
    type: stdout 
