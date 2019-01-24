cwlVersion: v1.0
class: CommandLineTool
id: sambamba_merge
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 2024
    coresMin: 36
  - class: DockerRequirement
    dockerPull: 'images.sbgenomics.com/bogdang/sambamba:0.6.3'
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |-
      ${
        var arr = [];
        if (inputs.bams.length > 1){
          for (var i=0; i<inputs.bams.length; i++){
            arr = arr.concat(inputs.bams[i].path)
          }
          var bams = arr.join(' ')
          return "/opt/sambamba_0.6.3/sambamba_v0.6.3 merge -t 36 " + " " + inputs.base_file_name + ".aligned.duplicates_marked.unsorted.bam " + bams;
        }
        else{
          return "mv " + inputs.bams[0].path + " " + inputs.base_file_name + ".aligned.duplicates_marked.unsorted.bam";
        }
      }

inputs:
  bams:
    type:
      type: array
      items: File
  base_file_name: string
outputs:
  merged_bam:
    type: File
    outputBinding:
      glob: '*.aligned.duplicates_marked.unsorted.bam'
    secondaryFiles: [.bai, ^.bai]
    format: BAM
