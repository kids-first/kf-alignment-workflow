cwlVersion: v1.0
class: CommandLineTool 
id: alignment_gate 
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'ubuntu:18.04'
baseCommand: ["/bin/bash","-c"]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      set -eo pipefail

      ${
        if (inputs.bam_list == null && inputs.pe_reads_list == null && inputs.se_reads_list == null) {
          return "echo No BAMs or FASTQs provided, mission accomplished >&2 && exit 1"
        } else {
          return "echo Files Provided...Processing >&2 && exit 0"
        }
      }

inputs:
  bam_list: ['null','File[]']
  pe_reads_list: ['null','File[]']
  pe_mates_list: ['null','File[]']
  pe_rgs_list: ['null','string[]']
  se_reads_list: ['null','File[]']
  se_rgs_list: ['null','string[]']
outputs:
  scatter_bams:
    doc: "If the bam list is null pass an empty scatter array. Otherwise pass the bam list for scattering."
    type: File[]
    outputBinding:
      outputEval:
        ${
          if (inputs.bam_list == null) {return []}
          else {return inputs.bam_list}
        }
  scatter_pe_reads:
    doc: "If the reads list is null, pass an empty scatter array. Otherwise pass the reads list for scattering." 
    type: File[]
    outputBinding:
      outputEval:
        ${
          if (inputs.pe_reads_list == null) {return []}
          else {return inputs.pe_reads_list}
        }
  scatter_pe_mates:
    doc: |-
      If the reads list is null, pass an empty scatter array. Otherwise pass the mates list for scattering."
    type: File[]
    outputBinding:
      outputEval:
        ${
          if (inputs.pe_reads_list == null) {return []}
          else {return inputs.pe_mates_list}
        }
  scatter_pe_rgs:
    doc: |-
      If the reads list is null, pass an empty scatter array. Otherwise pass the rgs list for scattering."
    type: string[]
    outputBinding:
      outputEval:
        ${
          if (inputs.pe_reads_list == null) {return []}
          else {return inputs.pe_rgs_list}
        } 
  scatter_se_reads:
    doc: "If the reads list is null, pass an empty scatter array. Otherwise pass the reads list for scattering."
    type: File[]
    outputBinding:
      outputEval:
        ${
          if (inputs.se_reads_list == null) {return []}
          else {return inputs.se_reads_list}
        }
  scatter_se_rgs:
    doc: |-
      If the reads list is null, pass an empty scatter array. Otherwise pass the rgs list for scattering."
    type: string[]
    outputBinding:
      outputEval:
        ${
          if (inputs.se_reads_list == null) {return []}
          else {return inputs.se_rgs_list}
        }
