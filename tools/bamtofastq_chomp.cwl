class: CommandLineTool
cwlVersion: v1.0
id: bamtofastq_chomp
doc: |-
  If the input BAM is not provided the program will simply exit without failing.
  This tool runs two programs:
    - samtools view && biobambam2 bamtofastq
  The program will first grab the RG header from the input BAM and put it in a file.
  This RG header in the text file is later parsed into a string.
  Next it will convert the bam to fastq. If the file is over the max_size, it will
  chunk the output FASTQ into 680 million line FASTQs (85 million read pairs).
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: '684194535433.dkr.ecr.us-east-1.amazonaws.com/d3b-healthomics:bwa-bundle-dev'
  - class: InlineJavascriptRequirement
baseCommand: ["/bin/bash", "-c"]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |-
      set -eo pipefail

      samtools view -H $(inputs.input_align.path) | grep ^@RG > rg.txt

      EXT=$(inputs.input_align.nameext.toLowerCase().substr(1))

      if [ $(inputs.input_align.size) -gt $(inputs.max_size) ]; then
        bamtofastq tryoq=1 filename=$(inputs.input_align.path) inputformat=$EXT ${
          if (inputs.reference != null){
              return "reference=" + inputs.reference.path;
            }
          else{
              return "";
            }
          } | split -dl 680000000 - reads-
        ls reads-* | xargs -i mv {} {}.fq
      else
        bamtofastq tryoq=1 filename=$(inputs.input_align.path) inputformat=$EXT ${
          if (inputs.reference != null){
              return "reference=" + inputs.reference.path;
            }
          else{
              return "";
            }
          } > reads-00.fq
      fi
inputs:
  input_align: { type: File, doc: "Input alignment file" }
  max_size: { type: 'long?', default: 20000000000, doc: "The maximum size (in bytes) that an input bam can be before the FASTQ is split" }
  reference: { type: 'File?', doc: "Fasta file if input is cram", secondaryFiles: [.fai] }
  cpu: { type: 'int?', default: 1, doc: "CPUs to allocate to this task." }
  ram: { type: 'int?', default: 2, doc: "GB of RAM to allocate to this task." }

outputs:
  output: { type: 'File[]', outputBinding: { glob: '*.fq' } }
  rg_string:
    type: File
    outputBinding:
      glob: rg.txt
