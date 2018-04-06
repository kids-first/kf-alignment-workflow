cwlVersion: v1.0
class: ExpressionTool
id: get_bwa_threads
requirements:
  - class: InlineJavascriptRequirement
inputs:
  input_files: File[]
outputs:
  threads: int

expression: >-
  ${if (inputs.input_files.length == 1) {thr = 36} else {thr = 18}; return
  {'threads':thr};}
