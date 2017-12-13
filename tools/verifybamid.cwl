cwlVersion: v1.0
class: CommandLineTool
id: verifybamid
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/verifybamid:1.0.1'
baseCommand: [VerifyBamID]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      --Verbose
      --NumPC 4
      --Output ${inputs.input_bam.nameroot}
      --BamFile ${inputs.input_bam.path}
      --Reference ${inputs.ref_fasta.path}
      --UDPath ${inputs.contamination_sites_ud.path}
      --MeanPath ${inputs.contamination_sites_mu.path}
      --BedPath ${inputs.contamination_sites_bed.path}
      1>/dev/null
inputs:
  input_bam:
    type: File
    secondaryFiles: [^.bai]
  ref_fasta:
    type: File
  contamination_sites_ud:
    type: File
  contamination_sites_mu:
    type: File
  contamination_sites_bed:
    type: File
outputs:
  - id: output
    type: File
    outputBinding:
      glob: '*.selfSM'
