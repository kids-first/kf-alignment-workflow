cwlVersion: v1.0
class: Workflow
id: kf-postbqsr-cavatica
requirements:
  - class: ScatterFeatureRequirement
hints:
  - class: sbg:AWSInstanceType
    value: r3.8xlarge;ebs-gp2;1024
  - class: sbg:maxNumberOfParallelInstances
    value: 2

inputs:
  input_final_bam:
    type: File
    secondaryFiles: [^.bai]
  indexed_reference_fasta:
    type: File
    secondaryFiles: [.64.amb, .64.ann, .64.bwt, .64.pac, .64.sa, .64.alt,
    ^.dict, .amb, .ann, .bwt, .pac, .sa, .fai]
  contamination_sites_ud: File
  contamination_sites_mu: File
  contamination_sites_bed: File
  wgs_coverage_interval_list: File
  wgs_calling_interval_list: File
  reference_dict: File
  wgs_evaluation_interval_list: File
  dbsnp_vcf:
    type: File
    secondaryFiles: [.idx]

outputs:
  gvcf:
    type: File
    outputSource: picard_mergevcfs/output
  cram:
    type: File
    outputSource: samtools_coverttocram/output
  collect_collect_aggregation_metrics:
    type: File[]
    outputSource: picard_collectaggregationmetrics/output1
  collect_collect_aggregation_pdf:
    type: File[]
    outputSource: picard_collectaggregationmetrics/output2
  collect_wgs_metrics:
    type: File
    outputSource: picard_collectwgsmetrics/output
  calculate_readgroup_checksum:
    type: File
    outputSource: picard_calculatereadgroupchecksum/output
  collect_readgroupbam_quality_metrics:
    type: File[]
    outputSource: picard_collectreadgroupbamqualitymetrics/output1
  collect_readgroupbam_quality_pdf:
    type: File[]
    outputSource: picard_collectreadgroupbamqualitymetrics/output2
  picard_collect_gvcf_calling_metrics:
    type: File[]
    outputSource: picard_collectgvcfcallingmetrics/output

steps:
  getbasename:
    run: ../../tools/expression_getbasename.cwl
    in:
      input_file: input_final_bam
    out: [file_basename]

  verifybamid:
    run: ../../tools/verifybamid.cwl
    in:
      input_bam: input_final_bam
      ref_fasta: indexed_reference_fasta
      contamination_sites_ud: contamination_sites_ud
      contamination_sites_mu: contamination_sites_mu
      contamination_sites_bed: contamination_sites_bed
    out: [output]

  picard_collectaggregationmetrics:
    run: ../../tools/picard_collectaggregationmetrics.cwl
    in:
      input_bam: input_final_bam
      reference: indexed_reference_fasta
    out: [output1, output2]

  picard_collectreadgroupbamqualitymetrics:
    run: ../../tools/picard_collectreadgroupbamqualitymetrics.cwl
    in:
      input_bam: input_final_bam
      reference: indexed_reference_fasta
    out: [output1, output2]

  picard_collectwgsmetrics:
    run: ../../tools/picard_collectwgsmetrics.cwl
    in:
      input_bam: input_final_bam
      reference: indexed_reference_fasta
      intervals: wgs_coverage_interval_list
    out: [output]

  picard_calculatereadgroupchecksum:
    run: ../../tools/picard_calculatereadgroupchecksum.cwl
    in:
      input_bam: input_final_bam
    out: [output]

  samtools_coverttocram:
    run: ../../tools/samtools_covert_to_cram.cwl
    in:
      input_bam: input_final_bam
      reference: indexed_reference_fasta
    out: [output]

  picard_intervallisttools:
    run: ../../tools/picard_intervallisttools.cwl
    in:
      interval_list: wgs_calling_interval_list
    out: [output]

  checkcontamination:
    run: ../../tools/expression_checkcontamination_2.cwl
    in: 
      verifybamid_selfsm: verifybamid/output
    out: [contamination]

  gatk_haplotypecaller:
    run: ../../tools/gatk_haplotypecaller_35.cwl
    in:
      reference: indexed_reference_fasta
      input_bam: input_final_bam
      interval_list: picard_intervallisttools/output
      contamination: checkcontamination/contamination
    scatter: [interval_list]
    out: [output]

  picard_mergevcfs:
    run: ../../tools/picard_mergevcfs.cwl
    in:
      input_vcf: gatk_haplotypecaller/output
      output_vcf_basename: getbasename/file_basename
    out:
      [output]

  picard_collectgvcfcallingmetrics:
    run: ../../tools/picard_collectgvcfcallingmetrics.cwl
    in:
      input_vcf: picard_mergevcfs/output
      reference_dict: reference_dict
      final_gvcf_base_name: getbasename/file_basename
      dbsnp_vcf: dbsnp_vcf
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
    out: [output]

