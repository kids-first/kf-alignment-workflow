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
baseCommand: [samtools, view]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      -b -T $(inputs.reference.path) -@ 35 $(inputs.input_cram.path) > tmp &&
      samtools view -H tmp | sed  "/^@RG/s/SM:\S\+/SM:$(inputs.base_file_name)/g" | samtools reheader -P - tmp > $(inputs.input_cram.nameroot).reheader.bam
      && samtools index -@ 35 $(inputs.input_cram.nameroot).reheader.bam $(inputs.input_cram.nameroot).reheader.bai
inputs:
  input_cram: File
  base_file_name: string
  reference: {type: File, secondaryFiles: [.fai]}
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.bam'
    secondaryFiles: [^.bai]
