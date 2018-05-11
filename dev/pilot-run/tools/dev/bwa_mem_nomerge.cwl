cwlVersion: v1.0
class: CommandLineTool
id: bwa_mem
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/bwa-picard:broad'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 5000
baseCommand: [java, -Xms5000m, -jar, /picard.jar]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      SamToFastq
      INPUT=$(inputs.input_bam.path)
      FASTQ=/dev/stdout
      INTERLEAVE=true
      NON_PF=true
      | bwa mem -K 100000000 -p -v 3 -t 16 -Y $(inputs.indexed_reference_fasta.path) -
      > $(inputs.input_bam.nameroot).aligned.unsorted.bam
inputs:
  input_bam:
    type: File
  indexed_reference_fasta:
    type: File
    secondaryFiles: [.64.amb, .64.ann, .64.bwt, .64.pac, .64.sa,
    ^.dict, .amb, .ann, .bwt, .pac, .sa]
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.input_bam.nameroot).aligned.unsorted.bam

