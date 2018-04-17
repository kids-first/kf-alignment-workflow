cwlVersion: v1.0
class: ExpressionTool
id: expression_checkcontamination
requirements:
  - class: InlineJavascriptRequirement

inputs:
  verifybamid_selfsm:
    type: File
    inputBinding:
      loadContents: true

outputs:
  contamination:
    type: float

expression:
  "${
      var contam = inputs.verifybamid_selfsm.contents.split('\\n')[1].split('\\t')[6];
      return {contamination: contam/0.75};
  }"  
