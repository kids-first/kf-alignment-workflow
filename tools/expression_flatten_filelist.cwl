cwlVersion: v1.2
class: ExpressionTool
id: expression_flatten_filelist
requirements:
  - class: InlineJavascriptRequirement

inputs:
  input_files:
    type:
      type: array
      items:
        type: array
        items: File

outputs:
  output_files: File[]

expression: |
  ${
    var flatten = function flatten(ary) {
        var ret = [];
        for(var i = 0; i < ary.length; i++) {
            if(Array.isArray(ary[i])) {
                ret = ret.concat(flatten(ary[i]));
            } else {
                ret.push(ary[i]);
            }
        }
        return ret;
    }
    return { output_files: flatten(inputs.input_files) };
  }
