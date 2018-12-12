class: CommandLineTool
cwlVersion: v1.0
id: samtools_split
label: Samtools split bam
doc: Use samtools 1.8 to split bam into smaller alignment jobs
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/samtools:1.8-dev'
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |-
      tar -xf $(inputs.bwa_index_tar.path) && RG_NUM=`samtools view -H $(inputs.input_bam.path) | grep -c ^@RG`
      if [ $RG_NUM != 1 ]; then
        samtools split -f '%!.bam' -@ 36 --reference $(inputs.reference.path) $(inputs.input_bam.path)
        rm $(inputs.input_bam.path)
      fi
inputs:
  input_bam: File
  bwa_index_tar: File[]
  reference: File
outputs:
  bam_files:
    type: File[]
    outputBinding:
      glob: '*.bam'
      outputEval: |-
        ${
          if (self.length == 0) return [inputs.input_bam]
          else return self
        }
  bwa_index:
    type: File[]
    outputBinding:
      glob: '*fasta*'