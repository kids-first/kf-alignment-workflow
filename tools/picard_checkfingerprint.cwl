cwlVersion: v1.0
class: CommandLineTool
id: picard_checkfingerprint
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.8.3'
  - class: ResourceRequirement
    ramMin: 8000
baseCommand: [ java, -Xms2000m, -Xmx8000m, -jar, /picard.jar, CheckFingerprint]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      INPUT=$(inputs.input_bam.path)
      OUTPUT=$(inputs.input_bam.nameroot).crosscheck
      SAMPLE_ALIAS=$(inputs.sample_alias)
      GENOTYPES=$(inputs.genotypes.path)
      HAPLOTYPE_MAP=$(inputs.haplotype_database_file.path)
      IGNORE_READ_GROUPS=true
inputs:
  input_bam:
    type: File
    secondaryFiles:
      - ^.bai
  genotypes:
    type: File?
  haplotype_database_file:
    type: File?
  sample_alias:
    type: string
outputs:
  - id: output
    type: File[]
    outputBinding:
      glob: '*_metrics'
