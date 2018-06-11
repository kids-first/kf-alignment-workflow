cwlVersion: v1.0
class: Workflow
id: kf_alignment_CramOnly_wf
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  input_reads: File
  biospecimen_name: string
  output_basename: string
  indexed_reference_fasta: File
  knownsites: File[]
  reference_dict: File
  # contamination_sites_bed: File
  # contamination_sites_mu: File
  # contamination_sites_ud: File
  wgs_coverage_interval_list: File
  wgs_evaluation_interval_list: File

outputs:
  cram: {type: File, outputSource: samtools_coverttocram/output}
  # verifybamid_output: {type: File, outputSource: verifybamid/output}
  bqsr_report: {type: File, outputSource: gatk_gatherbqsrreports/output}
  aggregation_metrics: {type: 'File[]', outputSource: picard_collectaggregationmetrics/output}
  wgs_metrics: {type: File, outputSource: picard_collectwgsmetrics/output}

steps:
  samtools_split:
    run: ../tools/samtools_split.cwl
    in:
      input_bam: input_reads
      reference: indexed_reference_fasta
    out: [bam_files]

  bwa_mem:
    run: ../workflows/kfdrc_bwamem_subwf.cwl
    in:
      input_reads: samtools_split/bam_files
      indexed_reference_fasta: indexed_reference_fasta
      sample_name: biospecimen_name
    scatter: [input_reads]
    out: [aligned_bams]

  sambamba_merge:
    run: ../tools/sambamba_merge.cwl
    in:
      bams: bwa_mem/aligned_bams
      base_file_name: output_basename
    out: [merged_bam]

  sambamba_sort:
    run: ../tools/sambamba_sort.cwl
    in:
      bam: sambamba_merge/merged_bam
      base_file_name: output_basename
    out: [sorted_bam]

  python_createsequencegroups:
    run: ../tools/python_createsequencegroups.cwl
    in:
      ref_dict: reference_dict
    out: [out_intervals]

  gatk_baserecalibrator:
    run: ../tools/gatk_baserecalibrator.cwl
    in:
      input_bam: sambamba_sort/sorted_bam
      knownsites: knownsites
      reference: indexed_reference_fasta
      sequence_interval: python_createsequencegroups/out_intervals
    scatter: [sequence_interval]
    out: [output]

  gatk_gatherbqsrreports:
    run: ../tools/gatk_gatherbqsrreports.cwl
    in:
      input_brsq_reports: gatk_baserecalibrator/output
      output_basename: output_basename
    out: [output]

  gatk_applybqsr:
    run: ../tools/gatk_applybqsr.cwl
    in:
      bqsr_report: gatk_gatherbqsrreports/output
      input_bam: sambamba_sort/sorted_bam
      reference: indexed_reference_fasta
      sequence_interval: python_createsequencegroups/out_intervals
    scatter: [sequence_interval]
    out: [recalibrated_bam]

  picard_gatherbamfiles:
    run: ../tools/picard_gatherbamfiles.cwl
    in:
      input_bam: gatk_applybqsr/recalibrated_bam
      output_bam_basename: output_basename
    out: [output]

  picard_collectaggregationmetrics:
    run: ../tools/picard_collectaggregationmetrics.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: indexed_reference_fasta
    out: [output]

  picard_collectwgsmetrics:
    run: ../tools/picard_collectwgsmetrics.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      intervals: wgs_coverage_interval_list
      reference: indexed_reference_fasta
    out: [output]

  # verifybamid:
  #   run: ../tools/verifybamid.cwl
  #   in:
  #     contamination_sites_bed: contamination_sites_bed
  #     contamination_sites_mu: contamination_sites_mu
  #     contamination_sites_ud: contamination_sites_ud
  #     input_bam: sambamba_sort/sorted_bam
  #     ref_fasta: indexed_reference_fasta
  #     output_basename: output_basename
  #   out: [output]

  samtools_coverttocram:
    run: ../tools/samtools_covert_to_cram.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: indexed_reference_fasta
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:AWSInstanceType'
    value: c4.8xlarge;ebs-gp2;850
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
