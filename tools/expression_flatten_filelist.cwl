cwlVersion: v1.2
class: ExpressionTool
id: expression_flatten_filelist
requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.max_memory * 1000 }
    coresMin: $(inputs.cores)

inputs:
  input_files:
    type:
      type: array
      items:
        type: array
        items: File
  max_memory: { type: 'int?', default: 36, doc: "GB of RAM to allocate to the task." }
  cores: { type: 'int?', default: 36, doc: "Minimum reserved number of CPU cores for the task." }

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
