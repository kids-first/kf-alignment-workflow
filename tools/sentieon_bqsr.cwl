cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_BaseRecalibrator
doc: |-
  This tool uses Sentieon software to perform base recalibration on a BAM.

  ### Inputs:
  - ``Reference``: Location of the reference FASTA file (Required)
  - ``Input bam``: Input bam file (Required)
  - ``Known sites``: Known polymorphic sites used to exclude regions from analysis (Required)
  - ``Interval``: Limit recalibration to specific regions (Optional)

  * Outputs are named based on the **prefix** input parameter. If a value for it is not provided, the base name of the provided **Input bam** inputs is used to name the outputs.
  * The **Output format** input parameter was added to allow the users to select the format of the created output file.

requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  coresMin: $(inputs.cpu_per_job)
  ramMin: $(inputs.mem_per_job)
- class: DockerRequirement
  dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202112_hifi_patched
- class: EnvVarRequirement
  envDef:
  - envName: SENTIEON_LICENSE
    envValue: $(inputs.sentieon_license)
- class: InlineJavascriptRequirement

inputs:
- id: sentieon_license
  label: Sentieon license
  doc: License server host and port
  type: string
- id: reference
  label: Reference
  doc: Reference fasta file with associated indexes
  type: File
  secondaryFiles:
  - pattern: .fai
    required: true
  - pattern: ^.dict
    required: false
  inputBinding:
      prefix: -r
      shellQuote: true
      position: 0
  sbg:fileTypes: FA, FASTA
- id: input_bam
  label: Input bam
  doc: Input bam file
  type: File
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
      prefix: -i
      shellQuote: true
      position: 0
  sbg:fileTypes: BAM, CRAM
- id: interval
  label: Interval
  doc: Interval string or file (BED/Picard)
  type: File?
  inputBinding:
      prefix: --interval
      shellQuote: true
      position: 0
  sbg:fileTypes: BED, VCF, interval_list
- id: known_sites
  label: Known sites
  doc: Known polymorphic sites (e.g. dbSNP)
  type:
  - type: array
    items: File
    inputBinding:
      separate: true
      prefix: -k
  secondaryFiles:
    - pattern: .tbi
      required: false
    - pattern: .idx
      required: false
  inputBinding:
    position: 15
    shellQuote: false
  sbg:fileTypes: VCF, VCF.GZ
- id: output_type
  label: Output format
  doc: |-
    Since Picard tools can output both SAM and BAM files, the users can choose the format of the output file.
  type:
  - 'null'
  - name: output_type
    type: enum
    symbols:
    - BAM
    - CRAM
    - SAME AS INPUT
  sbg:toolDefaultValue: SAME AS INPUT
- id: prefix
  label: Basename for output files
  doc: Basename for the output files that are to be written.
  type: string?
- id: cpu_per_job
  label: CPU per job
  doc: CPU per job
  type: int?
  default: 32
- id: mem_per_job
  label: Memory per job
  doc: Memory per job[MB]
  type: int?
  default: 32000
outputs:
- id: output_reads
  type: File
  outputBinding:
    glob: "*.*am"
  secondaryFiles:
    - pattern: .bai
      required: false 
    - pattern: .crai
      required: false
- id: recal_table
  type: File
  outputBinding:
    glob: "*.recal_data_Sentieon.table"
baseCommand:
- sentieon
- driver
arguments:
- prefix: '--algo'
  position: 10
  valueFrom: QualCal
  shellQuote: false
- prefix: ''
  position: 100
  valueFrom: |-
    ${
        var ext = inputs.output_type
        if (ext === "BAM")
        {
            var out_extension = ".bam"
        }
        else if (ext === "CRAM")
        {
            var out_extension = ".cram"
        }
        else
        {
            var out_extension = inputs.input_bam.nameext.toLowerCase()
        }
        if(inputs.prefix)
        {
            var table_name = inputs.prefix.concat('.recal_data_Sentieon.table');
            var output_name = inputs.prefix.concat(out_extension);
        }
        else{
            var table_name = inputs.input_bam.nameroot.concat('.recal_data_Sentieon.table');
            var output_name = inputs.input_bam.nameroot.concat(out_extension);
        }
        return table_name.concat(" && sentieon driver -r ").concat(inputs.reference.path).concat(" -i ").concat(inputs.input_bam.path).concat(" --read_filter QualCalFilter,table=").concat(table_name).concat(",prior=-1.0,indel=false,levels=10/20/30,min_qual=6 --algo ReadWriter ").concat(output_name)
    }
  shellQuote: false

$namespaces:
  sbg: https://sevenbridges.com
