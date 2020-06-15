cwlVersion: v1.0
class: CommandLineTool
id: untar_indexed_reference
baseCommand: [tar, xf]
inputs:
  reference_tar: 
    type: File
    inputBinding:
      position: 1
outputs:
  fasta:
    type: 'File'
    outputBinding:
      glob: '*.fasta' 
  dict:
    type: 'File'
    outputBinding:
      glob: '*.dict' 
  fai:
    type: 'File'
    outputBinding:
      glob: '*.fai' 
  alt:
    type: 'File?'
    outputBinding:
      glob: '*.64.alt'
  amb:
    type: 'File'
    outputBinding:
      glob: '*.64.amb' 
  ann:
    type: 'File'
    outputBinding:
      glob: '*.64.ann'
  bwt:
    type: 'File'
    outputBinding:
      glob: '*.64.bwt' 
  pac:
    type: 'File'
    outputBinding:
      glob: '*.64.pac' 
  sa: 
    type: 'File'
    outputBinding:
      glob: '*.64.sa' 
