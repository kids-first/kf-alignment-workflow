cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_HsMetricAlgo
doc: |-
  Run Sentieon QC tools.
  This tool performs the following QC tasks:
  HsMetricAlgo (Recommend for WXS or panel data)
  
  | Sentieon tool               	| GATK pipeline tool                      	| Description                                                                           	|
  |-----------------------------	|-----------------------------------------	|---------------------------------------------------------------------------------------	|
  | HsMetricAlgo                	| Picard CollectHsMetrics                 	| calculates the Hybrid Selection specific metrics for the sample                        	|

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
  #### Required for ``HsMetricAlgo``
  - ``Targets list``: location and filename of the interval list input file that contains the locations of the targets.
  - ``Baits list``: location and filename of the interval list input file that contains the locations of the baits used.
  
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
            return 12
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
            return 12000
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
- id: targets_list
  label: Targets list
  doc: |-
    Targets location interval list file (required)
  type: File
  inputBinding:
    prefix: --targets_list
    position: 11
    shellQuote: false
- id: baits_list
  label: Baits list
  doc: |-
    Baits location interval list file (required)
  type: File
  inputBinding:
    prefix: --baits_list
    position: 11
    shellQuote: false
- id: clip_overlapping_reads
  label: Clip overlapping reads
  doc: |-
    Clip overlapping reads (default: true)
  type:
  - 'null'
  - name: clip_overlapping_reads
    type: enum
    symbols:
    - 'true'
    - 'false'
  default: 'true'
  inputBinding:
    prefix: --clip_overlapping_reads
    position: 12
    shellQuote: false
  sbg:toolDefaultValue: 'true'
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
- id: cpu_per_job
  label: CPU per job
  doc: CPU per job
  type: int?
- id: mem_per_job
  label: Memory per job
  doc: Memory per job[MB].
  type: int?

outputs:
- id: hs_output
  type: File
  outputBinding:
    glob: '*.hs_metrics'

baseCommand:
- sentieon
- driver
arguments:
- prefix: ''
  position: 10
  valueFrom: --algo HsMetricAlgo
  shellQuote: false
- prefix: ''
  position: 100
  valueFrom: $(inputs.input_bam.nameroot).hs_metrics
  shellQuote: false
