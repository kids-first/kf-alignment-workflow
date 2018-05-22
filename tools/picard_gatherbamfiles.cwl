cwlVersion: v1.0
class: CommandLineTool
id: picard_gatherbamfiles
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.18.2-dev'
  - class: ResourceRequirement
    ramMin: 8000
baseCommand: []
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      rm_bams="${
        var arr = [];
        for (var i=0; i<inputs.input_bam.length; i++)
            arr = arr.concat(inputs.input_bam[i].path)
        return (arr.join(' '))
      }"

      input_bams="${
        var arr = [];
        for (var i=0; i<inputs.input_bam.length; i++)
            arr = arr.concat(inputs.input_bam[i].path)
        return (arr.join(' INPUT='))
      }"

      java -Xms2000m -jar /picard.jar GatherBamFiles
      OUTPUT=$(inputs.output_bam_basename).bam
      INPUT=$input_bams
      CREATE_INDEX=true
      CREATE_MD5_FILE=true
      &&
      rm $rm_bams
inputs:
  input_bam:
    type:
      type: array
      items: File
    secondaryFiles: [^.bai]
  output_bam_basename: string
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.bam'
    secondaryFiles: [^.bai, .md5]
