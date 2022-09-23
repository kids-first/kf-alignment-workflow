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
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/samtools:1.8-dev'
baseCommand: [samtools, view]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      -b -T $(inputs.reference.path) -@ $(inputs.threads) $(inputs.input_cram.path) > $(inputs.output_basename).bam
      && samtools index -@ $(inputs.threads) $(inputs.output_basename).bam $(inputs.output_basename).bai
inputs:
  input_cram: File
  output_basename: string
  threads: { type: 'int?', doc: "num threads to use", default: 8}
  reference: {type: File, secondaryFiles: [.fai]}
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.bam'
    secondaryFiles: [^.bai]
