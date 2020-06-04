cwlVersion: v1.0
class: CommandLineTool
id: tar
requirements:
  - class: InitialWorkDirRequirement
    listing: $(inputs.input_files)
baseCommand: [tar, cf]
inputs:
  tarfile:
    type: string
    inputBinding:
      position: 1
  input_files:
    type:
      type: array
      items: File 
      inputBinding:
        valueFrom: $(self.basename)
    inputBinding:
      position: 2
outputs:
  output: 
    type: File
    outputBinding:
      glob: $(inputs.tarfile)
