class: CommandLineTool
cwlVersion: v1.0
id: bwa_mem_naive
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 50000
    coresMin: 36
  - class: DockerRequirement
    dockerPull: '684194535433.dkr.ecr.us-east-1.amazonaws.com/d3b-healthomics:bwa-kf-bundle-0.1.17'
  - class: InlineJavascriptRequirement
baseCommand: ["/bin/bash", "-c"]
doc: |-
 The program can handle the following classes of inputs:
  - single end reads (only reads File and rg string provided)
  - reads with mates (reads File, mates File, and rg string provided)
  - interleaved reads (reads File provided, rg string provided, and interleaved set to true)
 This tool runs the following programs:
  - bwa mem | samblaster | sambamba view | sambamba sort
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      set -eo pipefail
      
      bwa mem -K 100000000 ${if (inputs.interleaved) {return '-p';} else {return ""}} -v 3 -t 36
      ${if (inputs.min_alignment_score == null) { return '';} else {return '-T ' + inputs.min_alignment_score;}}
      -Y $(inputs.ref.path) -R
  - position: 2
    shellQuote: false
    valueFrom: >-
      ${return inputs.reads.path}
      ${if (inputs.mates != null) {return inputs.mates.path} else {return ""}}
      | /opt/samblaster/samblaster -i /dev/stdin -o /dev/stdout
      | /opt/sambamba_0.6.3/sambamba_v0.6.3 view -t 36 -f bam -l 0 -S /dev/stdin
      | /opt/sambamba_0.6.3/sambamba_v0.6.3 sort -t 36 --natural-sort -m 15GiB --tmpdir ./
      -o ${if (inputs.reads != null) {return inputs.reads.nameroot} else {return ""}}.unsorted.bam -l 5 /dev/stdin
inputs:
  ref: { type: File, secondaryFiles: [.64.amb, .64.ann, .64.bwt, .64.pac, .64.sa, ^.dict, .fai], doc: "Reference fasta file with associated indexes" }
  reads: { type: File, doc: "Primary reads file" }
  mates: { type: 'File?', doc: "Mates file for the reads" }
  interleaved: { type: boolean, default: false, doc: "The reads input is interleaved" }
  min_alignment_score: { type: 'int?', doc: "Don't output alignment with score lower than INT. This option only affects output." }
  rg: { type: string, doc: "Formatted RG header to use in the resulting BAM, check BWA for formatting guidelines (e.g. escaped tabs '\t')", inputBinding: {position: 1, shellQuote: true} }

outputs:
  output: { type: File, outputBinding: { glob: '*.bam' } }
