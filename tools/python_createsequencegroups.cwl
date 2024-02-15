cwlVersion: v1.0
class: CommandLineTool
id: python_createsequencegroups
doc: |-
  Splits the reference dict file in a list of interval files. 
  Intervals are determined by the longest SQ length in the dict.
requirements:
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/python:2.7.13'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - writable: false
        entryname: "create_sequence_groups.py"
        entry:
          $include: ../scripts/create_sequence_groups.py
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |
      python create_sequence_groups.py $(inputs.ref_dict.path)
inputs:
  ref_dict: { type: File, doc: "Reference fasta dict file" }
outputs:
  sequence_intervals: { type: 'File[]', outputBinding: { glob: 'sequence_grouping_*.intervals' } }
  sequence_intervals_with_unmapped: { type: 'File[]', outputBinding: { glob: '*.intervals' } }
