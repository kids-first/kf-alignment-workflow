cwlVersion: v1.0
class: CommandLineTool
id: verifybamid_contamination
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/verifybamid:1.0.2'
  - class: ResourceRequirement
    ramMin: 5000
    coresMin: 4
baseCommand: [/bin/VerifyBamID]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      --Verbose
      --NumPC 4
      --Output $(inputs.output_basename)
      --BamFile $(inputs.input_bam.path)
      --Reference $(inputs.ref_fasta.path)
      --UDPath $(inputs.contamination_sites_ud.path)
      --MeanPath $(inputs.contamination_sites_mu.path)
      --BedPath $(inputs.contamination_sites_bed.path)
      1>/dev/null
inputs:
  input_bam: {type: File, secondaryFiles: [^.bai]}
  ref_fasta: {type: File, secondaryFiles: [.fai]}
  contamination_sites_ud: File
  contamination_sites_mu: File
  contamination_sites_bed: File
  output_basename: string
outputs:
  - id: output
    type: File
    outputBinding:
      glob: '*.selfSM'
  - id: contamination
    type: float
    outputBinding:
      glob: '*.selfSM'
      loadContents: true
      outputEval: |-
        ${
          var lines = self[0].contents.split('\n');
          for (var i = 1; i < lines.length; i++) {
            var fields = lines[i].split('\t');
            if (fields.length != 19) {
              continue;
            }
            return fields[6]/0.75;
          }
        }
