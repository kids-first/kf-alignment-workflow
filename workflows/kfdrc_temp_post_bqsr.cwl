cwlVersion: v1.0
class: Workflow
id: kf_alignment_hc_test_wf
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  input_reads: File
  output_basename: string
  indexed_reference_fasta: File
  dbsnp_vcf: File
  reference_dict: File
  contamination: float
  wgs_calling_interval_list: File
  wgs_coverage_interval_list: File
  wgs_evaluation_interval_list: File

outputs:
  cram: {type: File, outputSource: samtools_coverttocram/output}
  gvcf: {type: File, outputSource: picard_mergevcfs/output}
  gvcf_calling_metrics: {type: 'File[]', outputSource: picard_collectgvcfcallingmetrics/output}
  aggregation_metrics: {type: 'File[]', outputSource: picard_collectaggregationmetrics/output}
  wgs_metrics: {type: File, outputSource: picard_collectwgsmetrics/output}

steps:

  python_createsequencegroups:
    run: ../tools/python_createsequencegroups.cwl
    in:
      ref_dict: reference_dict
    out: [sequence_intervals, sequence_intervals_with_unmapped]

  picard_collectaggregationmetrics:
    run: ../tools/picard_collectaggregationmetrics.cwl
    in:
      input_bam: input_reads
      reference: indexed_reference_fasta
    out: [output]

  picard_collectwgsmetrics:
    run: ../tools/picard_collectwgsmetrics.cwl
    in:
      input_bam: input_reads
      intervals: wgs_coverage_interval_list
      reference: indexed_reference_fasta
    out: [output]

  picard_intervallisttools:
    run: ../tools/picard_intervallisttools.cwl
    in:
      interval_list: wgs_calling_interval_list
    out: [output]

  gatk_haplotypecaller:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: m5.2xlarge;ebs-gp2;500
    run: ../tools/gatk_haplotypecaller.cwl
    in:
      contamination: contamination
      input_bam: input_reads
      interval_list: picard_intervallisttools/output
      reference: indexed_reference_fasta
    scatter: [interval_list]
    out: [output]

  picard_mergevcfs:
    run: ../tools/picard_mergevcfs.cwl
    in:
      input_vcf: gatk_haplotypecaller/output
      output_vcf_basename: output_basename
    out: [output]

  picard_collectgvcfcallingmetrics:
    run: ../tools/picard_collectgvcfcallingmetrics.cwl
    in:
      dbsnp_vcf: dbsnp_vcf
      final_gvcf_base_name: output_basename
      input_vcf: picard_mergevcfs/output
      reference_dict: reference_dict
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
    out: [output]

  samtools_coverttocram:
    run: ../tools/samtools_covert_to_cram.cwl
    in:
      input_bam: input_reads
      reference: indexed_reference_fasta
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 8
