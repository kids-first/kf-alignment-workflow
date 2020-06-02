cwlVersion: v1.0
class: CommandLineTool
id: picard_gatherbamfiles
doc: |-
  This program gathers the input bam files into a single bam.
  The following programs are run in this program:
    - picard GatherBamFiles
    - rm
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
inputs:
  input_bam: { type: 'File[]', secondaryFiles: [^.bai], doc: "Input bam file list" }
  output_bam_basename: { type: string, doc: "String to be used as the base filename for the output." }
outputs:
  output: { type: File, outputBinding: { glob: '*.bam' }, secondaryFiles: [^.bai, .md5] }
