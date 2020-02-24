class: CommandLineTool
cwlVersion: v1.0
id: bwa_mem_naive
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 50000
    coresMin: 36
  - class: DockerRequirement
    dockerPull: 'zhangb1/bwa-kf-bundle:0.1.17'
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
      -Y $(inputs.ref.path)
      -R '${return inputs.rg}'
      ${return inputs.reads.path}
      ${if (inputs.mates != null) {return inputs.mates.path} else {return ""}}
      | /opt/samblaster/samblaster -i /dev/stdin -o /dev/stdout
      | /opt/sambamba_0.6.3/sambamba_v0.6.3 view -t 36 -f bam -l 0 -S /dev/stdin
      | /opt/sambamba_0.6.3/sambamba_v0.6.3 sort -t 36 --natural-sort -m 15GiB --tmpdir ./
      -o ${if (inputs.reads != null) {return inputs.reads.nameroot} else {return ""}}.unsorted.bam -l 5 /dev/stdin
inputs:
  ref:
    type: File
    secondaryFiles: [.64.amb, .64.ann, .64.bwt, .64.pac,
      .64.sa, .64.alt, ^.dict, .amb, .ann, .bwt, .pac, .sa]
  reads:
    type: File
    doc: "Primary reads."
  mates:
    type: File?
    doc: "Optional mates for the reads."
  interleaved:
    type: boolean
    default: false
    doc: "Is the reads input interleaved?"
  rg: string

outputs:
  output: { type: File, outputBinding: { glob: '*.bam' } }
