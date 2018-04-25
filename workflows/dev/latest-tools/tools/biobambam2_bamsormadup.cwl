class: CommandLineTool
cwlVersion: v1.0
id: biobambam2_bamsormadup
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    coresMin: 36
  - class: DockerRequirement
    dockerPull: 'zhangb1/kf-bwa-bundle'
  - class: InlineJavascriptRequirement
baseCommand: [bamsormadup]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      tmpfile=$(runtime.tmpdir)/tmpfile
      threads=36
      M=$(inputs.out_base).bamsormadup.metrics
      <$(inputs.input_bam.path)
      >$(inputs.out_base).aligned.duplicates_marked.sorted.bam
inputs:
  input_bam: File
  out_base: string
outputs:
  output: { type: File, outputBinding: { glob: '*.bam' } }
  metrics: { type: File, outputBinding: { glob: '*.metrics' } }
