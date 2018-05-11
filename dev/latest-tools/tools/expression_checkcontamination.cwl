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
  contamination: float

expression:
  "${
      var lines=inputs.verifybamid_selfsm.contents.split('\\n');
      for (var i=1; i<lines.length; i++){
        var fields=lines[i].split('\\t');
        if (fields.length != 19) {continue;}
        return {contamination: fields[6]/0.75};
      }
  }"  
