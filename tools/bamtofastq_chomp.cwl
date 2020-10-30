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
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/bwa-bundle:dev'
  - class: InlineJavascriptRequirement
baseCommand: ["/bin/bash", "-c"]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |-
      set -eo pipefail

      samtools view -H $(inputs.input_bam.path) | grep ^@RG > rg.txt

      if [ $(inputs.input_bam.size) -gt $(inputs.max_size) ]; then
        bamtofastq tryoq=1 filename=$(inputs.input_bam.path) | split -dl 680000000 - reads-
        ls reads-* | xargs -i mv {} {}.fq
      else
        bamtofastq tryoq=1 filename=$(inputs.input_bam.path) > reads-00.fq
      fi
inputs:
  input_bam: { type: File, doc: "Input bam file" }
  max_size: { type: long, default: 20000000000, doc: "The maximum size (in bytes) that an input bam can be before the FASTQ is split" }
#  sample: { type: string, doc: "String name of the sample used to relabel the rg string" }
outputs:
  output: { type: 'File[]', outputBinding: { glob: '*.fq' } }
  rg_string:
#    type: string
    type: File
    outputBinding:
      glob: rg.txt
#      loadContents: true
#      outputEval:
#        ${
#          var arr = self[0].contents.split('\n')[0].split('\t');
#          for (var i=1; i<arr.length; i++){
#            if (arr[i].startsWith('SM')){
#              arr[i] = 'SM:' + inputs.sample;
#            }
#          }
#          return arr.join('\\t');
#        }
