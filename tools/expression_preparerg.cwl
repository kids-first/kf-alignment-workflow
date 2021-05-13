cwlVersion: v1.0
class: ExpressionTool
id: expression_preparerg
requirements:
  - class: InlineJavascriptRequirement
inputs:
  rg:
    type: File?
    inputBinding: {loadContents: true}
  sample: { type: string }
outputs:
  rg_str: { type: string }

expression:
  "${
      if (inputs.rg == null) {return {rg_str: null}};
      var arr = inputs.rg.contents.split('\\n')[0].split('\\t');
      for (var i=1; i<arr.length; i++){
        if (arr[i].startsWith('SM')){
          arr[i] = 'SM:' + inputs.sample;
        }
      }
      return {rg_str: arr.join('\\\\t')};
    }"
