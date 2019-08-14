cwlVersion: v1.0
class: CommandLineTool
id: samtools_cram_reheader
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 4000
  - class: DockerRequirement
    dockerPull: 'kfdrc/samtools:1.8-dev'
baseCommand: ["/bin/bash", "-c"]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      set -eo pipefail

      samtools view
      -b -T $(inputs.reference.path) -@ 35 $(inputs.input_cram.path) > tmp &&
      samtools view -H tmp | sed  "/^@RG/s/SM:\S\+/SM:$(inputs.base_file_name)/g" | samtools reheader -P - tmp > $(inputs.output_basename).bam
      && samtools index -@ 35 $(inputs.output_basename).bam $(inputs.output_basename).bai
inputs:
  input_cram: File
  base_file_name: string
  output_basename: string
  reference: {type: File, secondaryFiles: [.fai]}
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.bam'
    secondaryFiles: [^.bai]
