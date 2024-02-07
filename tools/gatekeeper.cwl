cwlVersion: v1.0
class: CommandLineTool 
id: gatekeeper
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: '684194535433.dkr.ecr.us-east-1.amazonaws.com/d3b-healthomics:ubuntu'
baseCommand: ["/bin/bash","-c"]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      set -eo pipefail

      ${
        if (inputs.run_bam_processing || inputs.run_pe_reads_processing ||  inputs.run_se_reads_processing) {
          return "echo Files Provided...Processing >&2 && exit 0"
        } else {
          return "echo No BAMs or FASTQs provided, mission accomplished >&2 && exit 1"
        }
      }

inputs:
  run_bam_processing: boolean
  run_pe_reads_processing: boolean
  run_se_reads_processing: boolean
  run_hs_metrics: boolean
  run_wgs_metrics: boolean
  run_agg_metrics: boolean
  run_gvcf_processing: boolean
outputs:
  scatter_bams:
    type: int[]
    outputBinding:
      outputEval:
        ${
          if (inputs.run_bam_processing) {return [1]}
          else {return []}
        }
  scatter_pe_reads:
    type: int[]
    outputBinding:
      outputEval:
        ${
          if (inputs.run_pe_reads_processing) {return [1]}
          else {return []}
        }
  scatter_se_reads:
    type: int[]
    outputBinding:
      outputEval:
        ${
          if (inputs.run_se_reads_processing) {return [1]}
          else {return []}
        }
  scatter_hs_metrics:
    type: int[]
    outputBinding:
      outputEval:
        ${
          if (inputs.run_hs_metrics) {return [1]}
          else {return []}
        }
  scatter_wgs_metrics:
    type: int[]
    outputBinding:
      outputEval:
        ${
          if (inputs.run_wgs_metrics) {return [1]}
          else {return []}
        }
  scatter_agg_metrics:
    type: int[]
    outputBinding:
      outputEval:
        ${
          if (inputs.run_agg_metrics) {return [1]}
          else {return []}
        }
  scatter_gvcf:
    type: int[]
    outputBinding:
      outputEval:
        ${
          if (inputs.run_gvcf_processing) {return [1]}
          else {return []}
        }
