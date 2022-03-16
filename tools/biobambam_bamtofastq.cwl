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
      bamtofastq tryoq=1 filename=$(inputs.input_bam.path) > reads-00.fq
inputs:
  input_bam: { type: File, doc: "Input bam file" }
outputs:
  output: { type: 'File', outputBinding: { glob: '*.fq' } }

$namespaces:
  sbg: https://sevenbridges.com
