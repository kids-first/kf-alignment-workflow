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
      sed -i 's/\s/\\t/g' rg.txt # works for rabix, use \\ for cwltool
      ${
          if (inputs.input_bam.size > inputs.max_unit_byte) {
              var cmd = "";
              cmd += "bamtofastq tryoq=1 filename=" + inputs.input_bam.path;
              cmd += " | split -dl 1000 - reads- &&"
              cmd += " ls reads-* | xargs -i mv {} {}.fq";
              return cmd
          } else {
              return ""
          }
      }
inputs:
  input_bam: File
  max_unit_byte:
    type: int
    default: 50
outputs:
  output:
    type: File[]
    outputBinding:
      glob: '*.fq'
      outputEval: >-
        ${
          if( inputs.input_bam.size < inputs.max_unit_byte )
              return [inputs.input_bam]
          else return self
        }
  rg:
    type: File
    outputBinding:
      glob: rg.txt

