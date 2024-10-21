cwlVersion: v1.0
class: CommandLineTool
id: samtools_cram2bam_w_index
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 16000
    coresMin: $(inputs.threads)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/samtools:1.9'
baseCommand: [samtools, view, -b]
arguments:
  - position: 4
    shellQuote: false
    valueFrom: >-
      > $(inputs.output_basename).bam
      && samtools index -@ $(inputs.threads) $(inputs.output_basename).bam $(inputs.output_basename).bai
inputs:
  input_cram: { type: File, secondaryFiles: ['.crai'], doc: "cram file to convert",
    inputBinding: { position: 2 } }
  region: { type: 'string?', doc: "Specific region to pull, in format 'chr21' or 'chr3:1-1000'",
    inputBinding: { position: 3 } }
  output_basename: string
  threads: { type: 'int?', doc: "num threads to use", default: 8,
    inputBinding: { position: 1, prefix: "-@"} }
  reference: {type: File, secondaryFiles: [.fai], doc: "reference file use for cram",
    inputBinding: { position: 1, prefix: "--reference" } }
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.bam'
    secondaryFiles: [^.bai]
