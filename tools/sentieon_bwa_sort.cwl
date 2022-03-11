cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_bwa_mem
doc: |-
  This tool uses Sentieon BWA to align short reads and outputs a sorted BAM.
  
  ### Inputs:
  - ``Reference``: Location of the reference FASTA file (Required)
  - ``Reads``: Primary reads file (Required)
  - ``Mates``: Mates file for the reads (Optional)

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
  doc: Reference fasta file with associated indexes
  type: File
  inputBinding:
      shellQuote: true
      position: 50
  secondaryFiles:
  - pattern: .fai
    required: true
  - pattern: ^.dict
    required: true
  - pattern: .64.amb
    required: true
  - pattern: .64.ann
    required: true
  - pattern: .64.bwt
    required: true
  - pattern: .64.pac
    required: true
  - pattern: .64.sa
    required: true
  - pattern: .64.alt
    required: false
  sbg:fileTypes: FA, FASTA
- id: reads_forward
  label: Reads Forward
  doc: Primary reads file
  type: File
  inputBinding:
    shellQuote: true
    position: 51
- id: reads_mate
  label: Reads Reverse
  doc: Mates file for the reads
  type: File?
  inputBinding:
    shellQuote: true
    position: 52
- id: interleaved
  label: Interleaved
  doc: The reads input is interleaved.
  type: boolean?
  default: false
  inputBinding:
    prefix: -p
    shellQuote: true
    position: 10
  sbg:toolDefaultValue: 'false'
- id: min_alignment_score
  label: Min alignment score
  doc: minimum score to output
  type: int?
  inputBinding:
    prefix: -T
    shellQuote: true
    position: 10
  sbg:toolDefaultValue: '30'
- id: rg
  label: RG tag
  type: string
  doc: |-
    Formatted RG header to use in the resulting BAM, check BWA for formatting guidelines (e.g. @RG\tID:sampleid\tSM:sample\tPL:platform)
  inputBinding:
    prefix: -R
    position: 10
    shellQuote: true
- id: chunk_size
  label: Chunk size
  type: int?
  doc: |-
    Process INT input bases in each batch regardless of nThreads (for reproducibility)
  inputBinding:
    shellQuote: false
    position: 2
    valueFrom: |-
      ${
          if (self > 0)
              return "-K " + self
      }
  default: 100000000
- id: use_soft_clipping
  label: Use soft clipping
  doc: Use soft clipping for supplementary alignments.
  type: boolean?
  default: true
  inputBinding:
    prefix: -Y
    shellQuote: true
    position: 10
  sbg:toolDefaultValue: 'true'
- id: mark_shorter
  label: Mark shorter
  doc: Mark shorter split hits as secondary.
  type: boolean?
  default: false
  inputBinding:
    prefix: -M
    shellQuote: true
    position: 10
  sbg:toolDefaultValue: 'false'
- id: cpu_per_job
  label: CPU per job
  doc: CPU per job
  type: int?
- id: mem_per_job
  label: Memory per job
  doc: Memory per job[MB].
  type: int?
outputs:
- id: output
  type: File
  outputBinding:
    glob: "*.bam"
  secondaryFiles: 
    - pattern: .bai
      required: true
baseCommand:
- sentieon
- bwa
- mem
arguments:
- prefix: ''
  position: 1
  valueFrom: |-
    ${
        return "-t $(nproc)"
    }
  shellQuote: false
- prefix: ''
  position: 100
  valueFrom: |-
    ${
        return "| sentieon util sort -t $(nproc) -i - --sam2bam --bam_compression 1 -o " + inputs.reads_forward.nameroot + ".bam"
    }
  shellQuote: false
