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
  ${if (inputs.input_files.length == 1) {thr = 36} else if
  (inputs.input_files.length == 2) {thr = 18} else {thr = 9}; return
  {'threads':thr};}
