cwlVersion: v1.0
class: CommandLineTool
id: picard_markduplicates
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.8.3'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 8000
baseCommand: [java, -Dsamjdk.compression_level=2, -Xms4000m, -jar, /picard.jar, MarkDuplicates]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      OUTPUT=$(inputs.base_file_name).aligned.unsorted.duplicates_marked.bam
      METRICS_FILE=metrics_filename
      VALIDATION_STRINGENCY=SILENT
      OPTICAL_DUPLICATE_PIXEL_DISTANCE=2500
      ASSUME_SORT_ORDER=queryname
inputs:
  input_bams:
    type:
      type: array
      items: File
      inputBinding:
        prefix: INPUT=
        separate: false
  base_file_name: string
outputs: 
  output_markduplicates_bam:
    type: File
    outputBinding:
      glob: '*.bam'
