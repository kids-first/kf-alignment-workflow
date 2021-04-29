cwlVersion: v1.0
class: CommandLineTool
id: picard_mergevcfs
doc: |-
  This tool merges many VCFs into a single VCF.
  The following programs are run in this tool:
    - picard MergeVcfs
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 3000
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R'
baseCommand: [ java, -Xms2000m, -jar, /picard.jar, MergeVcfs]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      OUTPUT=$(inputs.output_vcf_basename).g.vcf.gz
inputs:
  input_vcf:
    type:
      type: array
      items: File
      inputBinding:
        prefix: INPUT=
        separate: false
    secondaryFiles: [.tbi]
    doc: "List of input VCF files"
  output_vcf_basename: { type: string, doc: "String to be used as the base filename for the output" }
outputs:
  output: { type: File, outputBinding: { glob: '*.vcf.gz' }, secondaryFiles: [.tbi] }
