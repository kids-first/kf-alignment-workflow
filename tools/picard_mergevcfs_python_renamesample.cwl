cwlVersion: v1.0
class: CommandLineTool
id: picard_mergevcfs_python_renamesample
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 3000
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.18.9'
baseCommand: [ java, -Xms2000m, -jar, /picard.jar, MergeVcfs]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      OUTPUT=/dev/stdout
      CREATE_INDEX=false |
      /VcfSampleRename.py $(inputs.biospecimen_name) |
      bgzip -c  > $(inputs.output_vcf_basename).g.vcf.gz &&
      tabix -p vcf $(inputs.output_vcf_basename).g.vcf.gz
inputs:
  input_vcf:
    type:
      type: array
      items: File
      inputBinding:
        prefix: INPUT=
        separate: false
    secondaryFiles:
      - .tbi
  output_vcf_basename:
    type: string
  biospecimen_name:
    type: string
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles:
      - .tbi