cwlVersion: v1.0
class: CommandLineTool
id: untar
baseCommand: [tar, xf]
inputs:
  tarfile:
    type: File
    inputBinding:
      position: 1
  extractfile:
    type: string
outputs:
  output: 
    type: 'File?'
    outputBinding:
      glob: $(inputs.extractfile)
