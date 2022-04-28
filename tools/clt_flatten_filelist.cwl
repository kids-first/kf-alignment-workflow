cwlVersion: v1.2
class: CommandLineTool 
id: clt_flatten_filelist
requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.max_memory * 1000 }
    coresMin: $(inputs.cores)

baseCommand: [echo, complete]

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
  output_files:
    type: File[]
    outputBinding:
      outputEval: |
        ${
            var ret = []
            for(var i=0; i < inputs.input_files.length; i++) {
                ret = ret.concat(inputs.input_files[i])
            }
            return ret
        }
