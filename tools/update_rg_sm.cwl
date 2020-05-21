cwlVersion: v1.0
class: CommandLineTool 
id: update_rg_sm 
requirements:
  - class: InlineJavascriptRequirement
baseCommand: [echo]
inputs:
  rg: 
    type: File
    inputBinding:
      loadContents: true
  sample: string
outputs:
  rg_str: 
    type: string
    outputBinding:
      outputEval:
        ${
          var arr = inputs.rg.contents.split('\n')[0].split('\t');
          for (var i=1; i<arr.length; i++){
            if (arr[i].startsWith('SM')){
              arr[i] = 'SM:' + inputs.sample;
            }
          }
          return arr.join('\\t');
        }
