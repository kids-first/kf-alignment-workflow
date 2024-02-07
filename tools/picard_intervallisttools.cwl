cwlVersion: v1.0
class: CommandLineTool
id: picard_intervallisttools
doc: |-
  This tool scatters a single interval list into many interval list files.
  The following programs are run in this tool:
    - picard IntervalListTools
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: '684194535433.dkr.ecr.us-east-1.amazonaws.com/d3b-healthomics:picard'
baseCommand: [java, -Xmx2000m, -jar, /picard.jar]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      IntervalListTools
      SCATTER_COUNT=50
      SUBDIVISION_MODE=BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW
      UNIQUE=true
      SORT=true
      BREAK_BANDS_AT_MULTIPLES_OF=1000000
      INPUT=$(inputs.interval_list.path)
      OUTPUT=$(runtime.outdir)
inputs:
  interval_list: { type: File, doc: "Input interval list" }
outputs:
  output: { type: 'File[]', outputBinding: { glob: 'temp*/*.interval_list' } }
