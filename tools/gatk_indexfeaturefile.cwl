cwlVersion: v1.0
class: CommandLineTool
id: gatk_indexfeaturefile
doc: "Creates an index for a feature file, e.g. VCF or BED file."
requirements:
  - class: DockerRequirement
    dockerPull: '684194535433.dkr.ecr.us-east-1.amazonaws.com/d3b-healthomics:gatk-4.1.7.0R'
  - class: InitialWorkDirRequirement
    listing: [$(inputs.input_file),$(inputs.input_index)]
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
  - class: ShellCommandRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      $(inputs.input_index ? 'echo /gatk' : '/gatk')
  - position: 1
    shellQuote: false
    valueFrom: >-
      IndexFeatureFile 
inputs:
  input_file:
    type: File
    doc: "Feature file (eg., VCF or BED file) to index. Must be in a tribble-supported format"
    inputBinding:
      position: 2
      prefix: "-I"
  input_index:
    type: 'File?'
    doc: "Index file for the input_file, if one exists"
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.input_file.basename)
    secondaryFiles: [.idx] 
