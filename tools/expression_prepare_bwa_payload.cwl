cwlVersion: v1.2
class: ExpressionTool
id: expression_preparerg
requirements:
  - class: InlineJavascriptRequirement
inputs:
  reads:
    type: File
  mates:
    type: File?
  rg_str:
    type: string
  interleaved:
    type: boolean?
outputs:
  bwa_payload:
    type:
      type: record
      fields:
        reads_file:
          type: File
        mates_file:
          type: File?
        rg_str:
          type: string
        interleaved:
          type: boolean

expression: |
  ${
    return {
      'bwa_payload': {
        'reads_file': inputs.reads,
        'mates_file': inputs.mates,
        'interleaved': inputs.interleaved != null,
        'rg_str': inputs.rg_str
      }
    }
  }

$namespaces:
  sbg: https://sevenbridges.com
