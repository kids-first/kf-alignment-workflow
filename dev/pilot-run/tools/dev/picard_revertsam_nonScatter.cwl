cwlVersion: v1.0
class: CommandLineTool
id: picard_revertsam
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.8.3'
  - class: ShellCommandRequirement
baseCommand: [java, -Xmx8000m, -jar, /picard.jar]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      RevertSam
      INPUT=$(inputs.input_bam.path)
      OUTPUT=$(runtime.outdir)
      SANITIZE=true
      MAX_DISCARD_FRACTION=0.005
      ATTRIBUTE_TO_CLEAR=XT
      ATTRIBUTE_TO_CLEAR=XN
      ATTRIBUTE_TO_CLEAR=AS
      ATTRIBUTE_TO_CLEAR=OP
      SORT_ORDER=queryname
      RESTORE_ORIGINAL_QUALITIES=true
      REMOVE_DUPLICATE_INFORMATION=true
      REMOVE_ALIGNMENT_INFORMATION=true
      OUTPUT_BY_READGROUP=true
inputs:
  input_bam: File
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.bam'
