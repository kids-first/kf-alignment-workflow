cwlVersion: v1.0
class: CommandLineTool
id: picard_mergevcfs
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.8.3'
baseCommand: [ java, '-Xms2000m', '-jar', /picard.jar, MergeVcfs]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      OUTPUT=$(inputs.output_bam_basename).g.vcf.gz
inputs:
  input_bam:
    type:
      type: array
      items: File
      inputBinding:
        prefix: INPUT=
        separate: false
    secondaryFiles:
      - .tbi
  output_bam_basename:
    type: string
outputs:
  output1:
    type: File
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles:
      - .tbi
