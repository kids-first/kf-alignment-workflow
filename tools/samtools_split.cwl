class: CommandLineTool
cwlVersion: v1.0
id: samtools_split
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/samtools:1.9'
  - class: InlineJavascriptRequirement
baseCommand: ["/bin/bash", "-c"]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |-
      set -eo pipefail

      ${
        if (inputs.input_bam == null) {
          return "echo No BAM was input, skipping BAM splitting >&2 && exit 0;"
        }
      }

      BAM_PATH=${if (inputs.input_bam != null) {return inputs.input_bam.path} else {return ""}}
      RG_NUM=`samtools view -H $BAM_PATH | grep -c ^@RG`
      if [ $RG_NUM != 1 ]; then
        samtools split -f '%!.bam' -@ 36 --reference $(inputs.reference.path) $BAM_PATH 
        rm $BAM_PATH 
      fi
inputs:
  input_bam: File?
  reference: File
outputs:
  bam_files:
    type: 'File[]'
    outputBinding:
      glob: '*.bam'
      outputEval: |-
        ${
          if (inputs.input_bam == null) return [ ] 
          if (self.length == 0) return [inputs.input_bam]
          else return self
        }
