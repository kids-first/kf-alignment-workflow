cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_WgsMetricsAlgo
doc: |-
  Run Sentieon QC tools.
  This tool performs the following QC tasks:
  WgsMetricsAlgo (Recommend for WGS)
  
  | Sentieon tool               	| GATK pipeline tool                      	| Description                                                                           	|
  |-----------------------------	|-----------------------------------------	|---------------------------------------------------------------------------------------	|
  | WgsMetricsAlgo               	| Picard CollectWgsMetrics                	| collects metrics related to the coverage and performance of WGS experiments            	|
  
  ### Inputs:
  #### Required for all tools
  - ``Reference``: Location of the reference FASTA file.
  - ``Input BAM``: Location of the BAM/CRAM input file.
  ##### Optional for all tools
  - ``Interval``: interval in the reference that will be used in all tools. This argument can be specified as:
    -  ``BED_FILE``: location of the BED file containing the intervals. 
    -  ``PICARD_INTERVAL_FILE``: location of the file containing the intervals, following the Picard interval standard.
    -  ``VCF_FILE``: location of VCF containing variant records whose genomic coordinates will be used as intervals.
  - ``Quality recalibration table``: location of the quality recalibration table output from the BQSR stage.

$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  coresMin: |-
    ${
        if (inputs.cpu_per_job)
        {
            return inputs.cpu_per_job
        }
        else
        {
            return 32
        }
    }
  ramMin: |-
    ${
        if (inputs.mem_per_job)
        {
            return inputs.mem_per_job
        }
        else
        {
            return 32000
        }
    }
- class: DockerRequirement
  dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202112.01_hifi
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
    shellQuote: false
  sbg:fileTypes: FA, FASTA
- id: input_bam
  label: Input BAM
  doc: Input BAM file
  type: File
  secondaryFiles:
  - pattern: ^.bai
    required: false
  - pattern: ^.crai
    required: false
  - pattern: .bai
    required: false
  - pattern: .crai
    required: false
  inputBinding:
    prefix: -i
    position: 1
    shellQuote: false
  sbg:fileTypes: BAM, CRAM
- id: interval
  label: Interval
  doc: |-
    An option for interval in the reference that will be used in the software.
  type: File?
  inputBinding:
    prefix: --interval
    position: 5
    shellQuote: false
  sbg:fileTypes: BED, VCF, interval_list
- id: recal_table
  label: Quality recalibration table
  doc: |-
    Location of the quality recalibration table output from the BQSR stage. 
    Do not use this option if the input BAM has already been recalibrated.
  type: File?
  inputBinding:
    prefix: -q
    position: 2
    shellQuote: false
- id: min_map_qual
  label: Min map qual
  doc: |-
    Minimum read mapping quality (default: 20)
  type: int?
  default: 20
  inputBinding:
    prefix: --min_map_qual
    position: 12
    shellQuote: false
  sbg:toolDefaultValue: '20'
- id: min_base_qual
  label: Min base qual
  doc: |-
    Minimum base quality (default: 20)
  type: int?
  default: 20
  inputBinding:
    prefix: --min_base_qual
    position: 12
    shellQuote: false
  sbg:toolDefaultValue: '20'
- id: coverage_cap
  label: Coverage cap
  doc: Maximum coverage limit for histogram
  type: int?
  inputBinding:
    prefix: --coverage_cap
    position: 12
    shellQuote: false
- id: include_unpaired
  label: Include unpaired reads
  doc: |-
    Count unpaired reads, and paired reads with one end unmapped (default: false)
  type:
  - 'null'
  - name: include_unpaired
    type: enum
    symbols:
    - 'true'
    - 'false'
  default: 'false'
  inputBinding:
    prefix: --include_unpaired
    position: 15
    shellQuote: false
  sbg:toolDefaultValue: 'false'
- id: base_qual_histogram
  label: Base quality histogram
  doc: |-
    Report base quality histogram (default:false)
  type:
  - 'null'
  - name: base_qual_histogram
    type: enum
    symbols:
    - 'true'
    - 'false'
  default: 'false'
  inputBinding:
    prefix: --base_qual_histogram
    position: 15
    shellQuote: false
  sbg:toolDefaultValue: 'false'
- id: sample_size
  label: Sample size
  doc: |-
     Sample Size used for Theoretical Het Sensitivity sampling (default: 10000)
  type: int?
  inputBinding:
    prefix: --sample_size
    position: 15
    shellQuote: false
- id: cpu_per_job
  label: CPU per job
  doc: CPU per job
  type: int?
- id: mem_per_job
  label: Memory per job
  doc: Memory per job[MB].
  type: int?

outputs:
- id: wgs_output
  type: File
  outputBinding:
    glob: '*.wgs_metrics'

baseCommand:
- sentieon
- driver
arguments:
- prefix: ''
  position: 10
  valueFrom: --algo WgsMetricsAlgo
  shellQuote: false
- prefix: ''
  position: 100
  valueFrom: $(inputs.input_bam.nameroot).wgs_metrics
  shellQuote: false
