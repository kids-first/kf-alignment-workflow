cwlVersion: v1.0
class: CommandLineTool
id: tabix_prep_knownsites
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    coresMin: 2
  - class: DockerRequirement
    dockerPull: 'migbro/samtools:1.9'
  - class: InitialWorkDirRequirement
    listing: $(inputs.knownsites)
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      ${
        var cmd = '';
        for(var i=0; i < inputs.knownsites.length; i++){
          cmd += 'tabix ' + inputs.knownsites[i].path + ';';
        }
       return cmd;
      }
inputs:
  knownsites:
    type: File[]
outputs:
  ks_indexed:
    type: File[]
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles: [.tbi]
