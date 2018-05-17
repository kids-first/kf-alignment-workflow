cwlVersion: v1.0
class: Workflow
id: paired_sample_qc_step2
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
inputs:
  gather_input_bam: File
  indexed_reference_fasta: File
  intervals: File

outputs:
  collect_collect_aggregation_metrics:
    type: File[]
    outputSource: picard_collectaggregationmetrics/output1
  collect_collect_aggregation_pdf:
    type: File[]
    outputSource: picard_collectaggregationmetrics/output2
  picard_collect_wgs_metrics:
    type: File
    outputSource: picard_collectwgsmetrics/output
  picard_calculate_readgroup_checksum:
    type: File
    outputSource: picard_calculatereadgroupchecksum/output
  samtools_covert_to_cram:
    type: File
    outputSource: samtools_coverttocram/output
  picard_validate_sam_file:
    type: File
    outputSource: picard_validatesamfile/output
  collect_readgroupbam_quality_metrics:
    type: File[]
    outputSource: picard_collectreadgroupbamqualitymetrics/output1
  collect_readgroupbam_quality_pdf:
    type: File[]
    outputSource: picard_collectreadgroupbamqualitymetrics/output2

steps:
  picard_collectaggregationmetrics:
    run: ../tools/picard_collectaggregationmetrics.cwl
    in:
      input_bam: gather_input_bam
      reference: indexed_reference_fasta
    out: [output1, output2]
  picard_collectreadgroupbamqualitymetrics:
    run: ../tools/picard_collectreadgroupbamqualitymetrics.cwl
    in:
      input_bam: gather_input_bam
      reference: indexed_reference_fasta
    out: [output1, output2]
  picard_collectwgsmetrics:
    run: ../tools/picard_collectwgsmetrics.cwl
    in:
      input_bam: gather_input_bam
      reference: indexed_reference_fasta
      intervals: intervals
    out: [output]
  picard_calculatereadgroupchecksum:
    run: ../tools/picard_calculatereadgroupchecksum.cwl
    in:
      input_bam: gather_input_bam
    out: [output]
  samtools_coverttocram:
    run: ../tools/samtools_covert_to_cram.cwl
    in:
      input_bam: gather_input_bam
      reference: indexed_reference_fasta
    out: [output]
  picard_validatesamfile:
    run: ../tools/picard_validatesamfile.cwl
    in:
      input_bam: samtools_coverttocram/output
      reference: indexed_reference_fasta
    out: [output]
