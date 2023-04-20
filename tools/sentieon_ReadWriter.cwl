cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_ReadWriter
doc: |-
  The **ReadWriter** algorithm outputs the result of applying the Base Quality Score Recalibration to a file.

  The **ReadWriter** algorithm can also merge BAM files, and/or convert them into cram files.

  The input to the **ReadWriter** algorithm is one or multiple BAM files and one or multiple recalibration tables; its output is the BAM file after recalibration. If the output file extension is CRAM, a CRAM file will be created. If multiple input files were used, the output file will be the result of merging all the files.

requirements:
- class: ShellCommandRequirement
- class: InlineJavascriptRequirement
- class: ResourceRequirement
  coresMin: |
    $(inputs.cpu_per_job ? inputs.cpu_per_job : 16)
  ramMin: |
    $(inputs.mem_per_job ? inputs.mem_per_job : 16000)
- class: DockerRequirement
  dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202112.01_hifi
- class: EnvVarRequirement
  envDef:
  - envName: SENTIEON_LICENSE
    envValue: $(inputs.sentieon_license)

$namespaces:
  sbg: https://sevenbridges.com

inputs:
- id: sentieon_license
  label: Sentieon License
  doc: License server host and port
  type: string
- id: reference
  label: Reference
  doc: Reference fasta with associated fai index
  type: File
  secondaryFiles:
  - pattern: .fai
    required: true
  - pattern: ^.dict
    required: true
  inputBinding:
    prefix: -r
    position: 0
  sbg:fileTypes: FA, FASTA
- id: input_bam
  label: Input BAM
  doc: Input BAM/CRAM files with index
  type:
    type: array
    items: File
    inputBinding:
      prefix: -i
      position: 0
  secondaryFiles:
  - pattern: .bai
    required: false
  - pattern: ^.bai
    required: false
  - pattern: .crai
    required: false
  - pattern: ^.crai
    required: false
  inputBinding:
    position: 1
  sbg:fileTypes: BAM, CRAM
- id: recal_table
  label: recal_table
  doc: |-
    Location of the quality recalibration table output from the BQSR stage. 
    Do not use this option if the input BAM has already been recalibrated.
  type:
  - 'null'
  - type: array
    inputBinding:
      prefix: -q
      separate: true
    items: File
  inputBinding:
    position: 2
- id: interval
  label: interval
  doc: An option for interval in the reference that will be used in the software.
  type: File?
  inputBinding:
    prefix: --interval
    position: 5
  sbg:fileTypes: BED, VCF, interval_list
- id: advanced_driver_options
  label: Advanced driver options
  doc: The options for driver call, e.g., --interval_padding, --read_filter.
  type: string[]?
  inputBinding:
    position: 6
- id: advanced_algo_options
  label: Advanced algo options
  doc: The options for --algo ReadWriter.
  type: string[]?
  inputBinding:
    position: 110
- id: output_file_name
  label: Output file name
  doc: Desired output file name (with an extension of either .BAM or .CRAM).
  type: string
  inputBinding:
    position: 150
- id: rm_cram_bai
  doc: BAI files are generated for CRAM files. If you don't want them, set this option.
  type: boolean?
- id: enable_tool
  type: boolean?
- id: cpu_per_job
  label: CPU per job
  doc: CPU per job
  type: int?
- id: mem_per_job
  label: Memory per job
  doc: Memory per job[MB].
  type: int?

outputs:
- id: output_reads
  type: File
  secondaryFiles:
  - pattern: .bai
    required: false
  - pattern: .crai
    required: false
  outputBinding:
    glob: '*.*am'

baseCommand:
- sentieon
- driver
arguments:
- prefix: --algo
  position: 100
  valueFrom: ReadWriter
- position: 999
  shellQuote: false
  valueFrom: |
    $(inputs.rm_cram_bai ? "&& rm *cram.bai" : "")
