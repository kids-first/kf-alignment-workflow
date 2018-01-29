cwlVersion: v1.0
class: ExpressionTool
id: expression_getbasename.cwl
requirements:
  - class: InlineJavascriptRequirement

inputs:
  input_file:
    type: File

outputs:
  file_basename:
    type: string

expression:
  "${return {file_basename: inputs.input_file.nameroot};}"  
