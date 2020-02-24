class: CommandLineTool
cwlVersion: v1.0
id: bamtofastq_chomp
doc: |-
  If the input BAM is not provided the program will simply exit without failing.
  This tool runs two programs:
    - samtools view && biobambam2 bamtofastq
  The program will first grab the RG header from the input BAM and put it in a file.
  Next it will convert the bam to fastq. If the file is over the max_size, it will
  chunk the output FASTQ into 680 million line FASTQs (85 million read pairs).
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'kfdrc/bwa-bundle:dev'
  - class: InlineJavascriptRequirement
baseCommand: ["/bin/bash", "-c"]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |-
      set -eo pipefail

      BAM_PATH=${return inputs.input_bam.path}

      samtools view -H $BAM_PATH | grep ^@RG > rg.txt

      if [ $BAM_PATH -gt $(inputs.max_size) ]; then
        bamtofastq tryoq=1 filename=$BAM_PATH | split -dl 680000000 - reads-
        ls reads-* | xargs -i mv {} {}.fq
        rm $BAM_PATH
      else
        bamtofastq tryoq=1 filename=$BAM_PATH > reads-00.fq
        rm $BAM_PATH
      fi
inputs:
  input_bam: File
  max_size:
    type: int
    default: 20000000000
    doc: "The maximum size (in bytes) that an input bam can be before the FASTQ is split."
outputs:
  output:
    type: File[]
    outputBinding:
      glob: '*.fq'
  rg:
    type: File
    outputBinding:
      glob: rg.txt
