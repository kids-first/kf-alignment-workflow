cwlVersion: v1.0
class: CommandLineTool
id: samtools_bam_to_cram
doc: |-
  This tool converts the input BAM into a CRAM.
  The following programs are run in this tool:
    - samtools view
    - samtools index
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 16000
    coresMin: $(inputs.threads)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/samtools:1.8-dev'
baseCommand: [samtools, view]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      -C -T $(inputs.reference.path) -@ $(inputs.threads) -o $(inputs.input_bam.nameroot).cram $(inputs.input_bam.path)
      && samtools index -@ $(inputs.threads) $(inputs.input_bam.nameroot).cram
inputs:
  reference: {type: File, secondaryFiles: [.fai], doc: "Reference fasta with associated fai index"}
  input_bam: {type: File, secondaryFiles: [^.bai], doc: "Input bam file"}
  threads: { type: 'int?', doc: "num threads to use", default: 8}
outputs:
  output: { type: File, outputBinding: { glob: '*.cram' }, secondaryFiles: [.crai] }
