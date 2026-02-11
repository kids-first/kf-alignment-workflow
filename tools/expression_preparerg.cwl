cwlVersion: v1.2
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

expression: |
  ${
      if (inputs.rg == null) { return { rg_str: null }}
      var required_fields = ["ID", "SM", "LB", "PL"]
      var rg_fields = inputs.rg.contents.trim().split('\t')
      for (var index in rg_fields) {
          var field = rg_fields[index]
          if (field.startsWith("SM:")) {
              rg_fields[index] = 'SM:' + inputs.sample
          }
          var key = field.split(":")[0]
          if (required_fields.indexOf(key) > -1) {
              required_fields.splice(required_fields.indexOf(key), 1)
          }
      }
      if (required_fields.length > 0) {
          throw new Error("Missing Required RG Fields: " + required_fields.join(','))
      }
      return {rg_str: rg_fields.join('\\t')}
  }
