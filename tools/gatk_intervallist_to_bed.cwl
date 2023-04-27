cwlVersion: v1.0
class: CommandLineTool
id: gatk4_intervallist2bed
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.1.1.0'
  - class: ResourceRequirement
    ramMin: 2000

baseCommand: [/gatk, IntervalListToBed, --java-options, -Xmx100m]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      -O $(inputs.interval_list.nameroot).bed

inputs:
  interval_list: { type: File, doc: "Interval list to convert",
    inputBinding: { position: 0, prefix: "-I"} }
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.bed'
