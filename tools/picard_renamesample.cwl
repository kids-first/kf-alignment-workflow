cwlVersion: v1.0
class: CommandLineTool
id: picard_renamesample
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.18.2-dev'
baseCommand: [java, -Xmx2000m, -jar, /picard.jar]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      RenameSampleInVcf
      INPUT=$(inputs.gvcf.path)
      OUTPUT=$(inputs.gvcf.nameroot).gz
      NEW_SAMPLE_NAME=$(inputs.biospecimen_name)
      CREATE_INDEX=true
inputs:
  gvcf: File
  biospecimen_name: string
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles: [.tbi]
