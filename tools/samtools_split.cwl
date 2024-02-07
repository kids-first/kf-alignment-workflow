class: CommandLineTool
cwlVersion: v1.2
id: samtools_split
doc: |-
  This tool splits the input bam input read group bams if it has more than one readgroup.
  Programs run in this tool:
    - samtools view | grep
    - samtools split
  Using samtools view and grep count the header lines starting with @RG. If that number is
  not one, split the bam file into read group bams using samtools.
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: '684194535433.dkr.ecr.us-east-1.amazonaws.com/d3b-healthomics:samtools'
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: ${ return inputs.max_memory * 1000 }
    coresMin: $(inputs.cores)
baseCommand: ["/bin/bash", "-c"]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |-
      set -eo pipefail
      RG_NUM=`samtools view -H $(inputs.input_bam.path) | grep -c ^@RG`
      if [ $RG_NUM != 1 ]; then
        samtools split -f '%!.bam' -@ $(inputs.cores) --reference $(inputs.reference.path) $(inputs.input_bam.path)
      fi
inputs:
  input_bam: { type: File, doc: "Input bam file" }
  reference: { type: File, doc: "Reference fasta file" }
  max_memory: { type: 'int?', default: 36, doc: "GB of RAM to allocate to the task." }
  cores: { type: 'int?', default: 36, doc: "Minimum reserved number of CPU cores for the task." }
outputs:
  bam_files:
    type: File[]
    outputBinding:
      glob: '*.bam'
      outputEval: |-
        ${
          if (self.length == 0) return [inputs.input_bam]
          else return self
        }
