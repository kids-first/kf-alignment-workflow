cwlVersion: v1.0
class: CommandLineTool
id: picard_sortsam
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.8.3'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 8000
baseCommand: [java, -Xmx8000m, -jar, /picard.jar]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      SortSam
      INPUT=$(inputs.input_bam.path)
      OUTPUT=${
        if(inputs.base_file_name=="default"){
          var names = inputs.input_bam.nameroot.split(".")
          names.splice(-3)
          return names.join(".")
        }else{
          return inputs.base_file_name
        }
      }.aligned.duplicates_marked.sorted.bam
      SORT_ORDER="coordinate"
      CREATE_INDEX=true
      CREATE_MD5_FILE=true
      MAX_RECORDS_IN_RAM=400000
inputs:
  input_bam:
    type: File
  base_file_name: 
    type: string?
    default: default
outputs:
  output_sorted_bam:
    type: File
    outputBinding:
      glob: '*.sorted.bam'
    secondaryFiles: [^.bai, .md5]
