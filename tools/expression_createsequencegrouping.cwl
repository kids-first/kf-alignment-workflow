cwlVersion: v1.0
class: ExpressionTool
id: expression_createsequencegrouping
requirements:
  - class: InlineJavascriptRequirement

inputs:
  sequence_grouping_tsv:
    type: File
    inputBinding:
      loadContents: true

outputs:
  sequence_grouping_array:
    type: Any

expression:
  "${
      var lines = inputs.sequence_grouping_tsv.contents.split('\\n');
      var nline = lines.length;
      var eachgroup = [];
      var grouparray = {};
      for (var i = 0; i < nline; i++) {
        eachgroup.push(lines[i].split('\\t'));
        grouparray[i] = lines[i].split('\\t');
      }
      return {'output': grouparray};
  }"  
