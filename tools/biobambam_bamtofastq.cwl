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
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
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
  reference: { type: 'File?', doc: "Fasta file if input is cram", secondaryFiles: [.fai], inputBinding: { position: 1, prefix: "reference=", separate: false } }
  rg_str: { type: 'string?', default: "NO RG PROVIDED", doc: "Read group string taken from the input_align file. Used for bwa_payload record creation." }
  cpu: { type: 'int?', default: 1, doc: "CPUs to allocate to this task." }
  ram: { type: 'int?', default: 2, doc: "RAM in GBs to allocate to this task." }
outputs:
  output: { type: 'File', outputBinding: { glob: '*.fq' } }
  bwa_payload:
    type:
      type: record
      fields:
        reads_file:
          type: File
          outputBinding:
            glob: '*.fq'
        mates_file:
          type: File?
          outputBinding:
            outputEval: $(null)
        rg_str:
          type: string
          outputBinding:
            outputEval: $(inputs.rg_str)
        interleaved:
          type: boolean
          outputBinding:
            outputEval: $(1 == 1)

$namespaces:
  sbg: https://sevenbridges.com
