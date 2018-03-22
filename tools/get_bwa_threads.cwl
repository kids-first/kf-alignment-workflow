class: ExpressionTool
cwlVersion: v1.0
baseCommand: []
inputs:
  - id: input_files
    type: 'File[]'
outputs:
  - id: threads
    type: int
    outputBinding: {}
label: get_bwa_threads
requirements:
  - class: InlineJavascriptRequirement
expression: >-
  ${if (inputs.input_files.length == 1) {thr = 36} else {thr = 18}; return
  {'threads':thr};}
