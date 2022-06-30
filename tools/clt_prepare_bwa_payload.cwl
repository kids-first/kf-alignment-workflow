cwlVersion: v1.2
class: CommandLineTool
id: clt_prepare_bwa_payload
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

baseCommand: [echo, complete]
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
          outputBinding:
            outputEval: $(inputs.reads)
        mates_file:
          type: File?
          outputBinding:
            outputEval: $(inputs.mates)
        rg_str:
          type: string
          outputBinding:
            outputEval: $(inputs.rg_str)
        interleaved:
          type: boolean
          outputBinding:
            outputEval: $(inputs.interleaved == true)
