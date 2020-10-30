class: CommandLineTool
cwlVersion: v1.0
id: fastq_chomp
doc: |-
  This tool will chomp any fastq larger than the max size (10 gb by default) into 320000000 line chunks (80M reads). 
  Programs used in this tool:
    - zcat | split
    - ls | mv
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 8000
    coresMin: 4
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/bwa-bundle:dev'
  - class: InlineJavascriptRequirement
baseCommand: ["/bin/bash", "-c"]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |-
      set -eo pipefail

      if [ $(inputs.input_fastq.size) -gt $(inputs.max_size) ]; then
        zcat $(inputs.input_fastq.path) | split -dl 320000000 - reads-
        ls reads-* | xargs -i mv {} {}.fq
      else
        echo "FASTQ not large enough to split."
      fi
inputs:
  input_fastq: {type: File, doc: "Input fastq file" }
  max_size: { type: long, default: 10000000000, doc: "The maximum size (in bytes) that an input bam can be before the FASTQ is split" }
outputs:
  output:
    type: File[]
    outputBinding:
      glob: '*.fq'
      outputEval: |-
        ${
          if (self.length == 0) return [inputs.input_fastq]
          else return self
        }
