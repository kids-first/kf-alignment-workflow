class: CommandLineTool
cwlVersion: v1.2
id: biobambam_bamtofastq
doc: |-
  If the input BAM is not provided the program will simply exit without failing.
  This tool runs:
    - biobambam2 bamtofastq
  It will convert the bam to fastq.
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 1000
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/bwa-bundle:dev'
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |-
      bamtofastq tryoq=1 inputformat=$(inputs.input_align.nameext.toLowerCase().substr(1))
  - position: 2
    shellQuote: false
    valueFrom: |-
      > reads-00.fq
inputs:
  input_align: { type: File, doc: "Input alignment file", inputBinding: { position: 1, prefix: "filename=", separate: false } }
  reference: { type: 'File?', doc: "Fasta file if input is cram", secondaryFiles: [.fai],
    inputBinding: { position: 1, prefix: "reference=", separate: false } }
outputs:
  output: { type: 'File', outputBinding: { glob: '*.fq' } }

$namespaces:
  sbg: https://sevenbridges.com
