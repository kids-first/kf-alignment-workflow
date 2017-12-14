cwlVersion: v1.0
class: Workflow
id: scatter_bqsr
requirements:
  - class: ScatterFeatureRequirement

inputs:
  sequence_grouping_tsv:
    type: File
    inputBinding:
      loadContents: true
  knownsites: File[]
  reference: File
  input_bam: File

outputs:
  output_recal_data:
    type: File[]
    outputSource: gatkv4_baserecalibrator/output

steps:
  createsequencegrouping:
    run: expression_createsequencegrouping.cwl
    in:
      sequence_grouping_tsv: sequence_grouping_tsv
    out: [sequence_grouping_array]

  gatkv4_baserecalibrator:
    run: gatk_baserecalibrator.cwl
    in:
      input_bam: input_bam
      knownsites: knownsites
      reference: reference
      sequence_interval: createsequencegrouping/sequence_grouping_array
    scatter: [sequence_interval]
    out: [output]
