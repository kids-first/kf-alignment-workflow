class: CommandLineTool
cwlVersion: v1.0
id: bamtofastq_chomp
doc: |-
  This tool will chomp any fastq larger than 10 gb into 320000000 line chunks (80M reads). 
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

      FASTQ_PATH=${return inputs.input_fastq.path}

      if [ $FASTQ_PATH -gt $(inputs.max_size) ]; then
        cat $FASTQ_PATH | split -dl 680000000 - reads-
        ls reads-* | xargs -i mv {} {}.fq
        rm $FASTQ_PATH
      else
        echo "FASTQ not split." 
      fi
inputs:
  input_fastq: File
  max_size:
    type: int
    default: 10000000000
    doc: "The maximum size (in bytes) that an input bam can be before the FASTQ is split."
outputs:
  output:
    type: File[]
    outputBinding:
      glob: '*.fq'
