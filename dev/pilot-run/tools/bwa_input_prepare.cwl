class: CommandLineTool
cwlVersion: v1.0
id: bwa_input_prepare
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'zhangb1/kf-bwa-bundle'
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |-
      samtools view -H $(inputs.input_bam.path) | grep ^@RG > rg.txt
      if [ $(inputs.input_bam.size) -gt $(inputs.max_siz) ]; then
        bamtofastq tryoq=1 filename=$(inputs.input_bam.path) | split -dl 680000000 - reads-
        ls reads-* | xargs -i mv {} {}.fq
      fi
inputs:
  input_bam: File
  max_siz:
    type: int
    default: 20000000000
outputs:
  output:
    type: File[]
    outputBinding:
      glob: '*.fq'
      outputEval: >-
        ${
          if( inputs.input_bam.size < inputs.max_siz ) return [inputs.input_bam]
          else return self
        }
  rg:
    type: File
    outputBinding:
      glob: rg.txt
