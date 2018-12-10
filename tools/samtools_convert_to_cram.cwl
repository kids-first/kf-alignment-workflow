cwlVersion: v1.0
class: CommandLineTool
id: samtools_convert_to_cram
label: Samtools bam2cram
doc: Converts final resultant bam to cram format
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
      -C -T $(inputs.reference.path) -o $(inputs.input_bam.nameroot).cram $(inputs.input_bam.path)
      && samtools index $(inputs.input_bam.nameroot).cram
inputs:
  reference_fasta: File
  reference_fai: File
  input_bam: {type: File, secondaryFiles: [^.bai]}
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.cram'
    secondaryFiles: [.crai]
