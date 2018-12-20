cwlVersion: v1.0
class: CommandLineTool
id: tabix_untar_prep
label: Tabix ks bwa prep
doc: Index known sites files for bqsr and  and untar bwa index for next steps for alignments jobs
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    coresMin: 2
  - class: DockerRequirement
    dockerPull: 'kfdrc/samtools:1.9'
  - class: InitialWorkDirRequirement
    listing: $(inputs.knownsites)
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      tar -xf $(inputs.bwa_index_tar.path) &&
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
  bwa_index_tar: File
outputs:
  ks_indexed:
    type: File[]
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles: [.tbi]
  bwa_index:
    type: File[]
    outputBinding:
      glob: '*fasta*'
