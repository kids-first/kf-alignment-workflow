cwlVersion: v1.2
class: CommandLineTool
id: untar_indexed_reference
baseCommand: [tar, xf]
inputs:
  reference_tar: 
    type: File
    inputBinding:
      position: 1
outputs:
  indexed_fasta:
    type: 'File'
    secondaryFiles: [{ pattern: '^.dict', required: true }, { pattern: '.fai', required: true }, { pattern: '.64.alt', required: false }, { pattern: '.64.amb', required: true }, { pattern: '.64.ann', required: true }, { pattern: '.64.bwt', required: true }, { pattern: '.64.pac', required: true }, { pattern: '.64.sa', required: true }]
    outputBinding:
      glob: '*.fasta' 
  dict:
    type: 'File'
    outputBinding:
      glob: '*.dict' 
